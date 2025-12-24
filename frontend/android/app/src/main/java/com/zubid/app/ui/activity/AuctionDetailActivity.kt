package com.zubid.app.ui.activity

import android.content.Context
import android.content.Intent
import android.graphics.Paint
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.zubid.app.R
import com.zubid.app.data.api.ApiClient
import com.zubid.app.data.local.SessionManager
import com.zubid.app.data.model.Auction
import com.zubid.app.data.model.BidRequest
import com.zubid.app.data.model.BuyNowResponse
import com.zubid.app.data.websocket.AuctionStatus
import com.zubid.app.data.websocket.BidHistoryItem
import com.zubid.app.data.websocket.BidUpdate
import com.zubid.app.data.websocket.ConnectionState
import com.zubid.app.data.websocket.WebSocketManager
import com.zubid.app.databinding.ActivityAuctionDetailBinding
import com.zubid.app.ui.adapter.BidHistoryAdapter
import com.zubid.app.util.LocaleHelper
import com.zubid.app.util.NotificationHelper
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import java.text.NumberFormat
import java.util.*

class AuctionDetailActivity : AppCompatActivity() {

    private lateinit var binding: ActivityAuctionDetailBinding
    private lateinit var sessionManager: SessionManager
    private lateinit var webSocketManager: WebSocketManager
    private lateinit var bidHistoryAdapter: BidHistoryAdapter
    private var auction: Auction? = null
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var timerRunnable: Runnable
    private var currentAuctionId: String = ""
    private var isBidHistoryExpanded = true
    private val bidHistory = mutableListOf<BidHistoryItem>()

    companion object {
        const val EXTRA_AUCTION_ID = "auction_id"
        const val EXTRA_AUCTION_TITLE = "auction_title"
        const val EXTRA_AUCTION_IMAGE = "auction_image"
        const val EXTRA_AUCTION_PRICE = "auction_price"
        const val EXTRA_AUCTION_END_TIME = "auction_end_time"
        const val EXTRA_AUCTION_BID_COUNT = "auction_bid_count"
        const val EXTRA_AUCTION_DESCRIPTION = "auction_description"
        const val EXTRA_AUCTION_REAL_PRICE = "auction_real_price"
        const val EXTRA_AUCTION_MARKET_PRICE = "auction_market_price"
    }

    override fun attachBaseContext(newBase: Context) {
        super.attachBaseContext(LocaleHelper.onAttach(newBase))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityAuctionDetailBinding.inflate(layoutInflater)
        setContentView(binding.root)

        sessionManager = SessionManager(this)
        webSocketManager = WebSocketManager.getInstance()

        NotificationHelper.createNotificationChannels(this)

        setupViews()
        setupBidHistory()
        loadAuctionFromIntent()
        loadDemoBidHistory()
        startTimer()
        setupWebSocket()
    }

    private fun setupViews() {
        binding.btnBack.setOnClickListener { finish() }

        binding.btnWishlist.setOnClickListener {
            if (!sessionManager.isLoggedIn()) {
                Toast.makeText(this, getString(R.string.please_login_to_bid), Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            Toast.makeText(this, "Added to wishlist", Toast.LENGTH_SHORT).show()
        }

        binding.btnShare.setOnClickListener {
            shareAuction()
        }

        binding.btnPlaceBid.setOnClickListener {
            placeBid()
        }

        binding.btnBuyNow.setOnClickListener {
            showBuyNowConfirmation()
        }

        binding.btnContactSeller.setOnClickListener {
            if (!sessionManager.isLoggedIn()) {
                Toast.makeText(this, getString(R.string.please_login_to_bid), Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            // Open chat with seller
            startActivity(Intent(this, ChatActivity::class.java).apply {
                putExtra("user_id", "seller_1")
                putExtra("user_name", "Seller")
                putExtra("user_avatar", "")
            })
        }

        binding.tvShowAllBids.setOnClickListener {
            toggleBidHistory()
        }

        // Add input validation for bid amount
        binding.inputBidAmount.setOnFocusChangeListener { _, hasFocus ->
            if (!hasFocus) {
                validateBidInput()
            }
        }
    }

    private fun shareAuction() {
        auction?.let { currentAuction ->
            val shareText = "Check out this auction: ${currentAuction.title}\n" +
                    "Current Price: ${formatPrice(currentAuction.currentPrice)}\n" +
                    "Time Left: ${currentAuction.getTimeRemaining()}"

            val shareIntent = Intent().apply {
                action = Intent.ACTION_SEND
                putExtra(Intent.EXTRA_TEXT, shareText)
                type = "text/plain"
            }
            startActivity(Intent.createChooser(shareIntent, "Share Auction"))
        }
    }

    private fun validateBidInput(): Boolean {
        val bidAmountText = binding.inputBidAmount.text.toString().trim()
        if (bidAmountText.isEmpty()) {
            return true // Empty is okay, will be validated on submit
        }

        val bidAmount = try {
            bidAmountText.toDouble()
        } catch (e: NumberFormatException) {
            binding.inputBidAmount.error = getString(R.string.enter_valid_bid)
            return false
        }

        if (bidAmount <= 0) {
            binding.inputBidAmount.error = getString(R.string.enter_valid_bid)
            return false
        }

        auction?.let { currentAuction ->
            val bidIncrement = 1.0
            val minimumBid = currentAuction.currentPrice + bidIncrement

            if (bidAmount < minimumBid) {
                binding.inputBidAmount.error = "Minimum bid: ${formatPrice(minimumBid)}"
                return false
            }
        }

        binding.inputBidAmount.error = null
        return true
    }

    private fun setupBidHistory() {
        bidHistoryAdapter = BidHistoryAdapter(sessionManager.getUserId())
        binding.rvBidHistory.layoutManager = LinearLayoutManager(this)
        binding.rvBidHistory.adapter = bidHistoryAdapter
    }

    private fun toggleBidHistory() {
        isBidHistoryExpanded = !isBidHistoryExpanded
        if (isBidHistoryExpanded) {
            binding.rvBidHistory.visibility = View.VISIBLE
            binding.tvShowAllBids.text = getString(R.string.hide_bids)
        } else {
            binding.rvBidHistory.visibility = View.GONE
            binding.tvShowAllBids.text = getString(R.string.show_all_bids, bidHistory.size)
        }
    }

    private fun loadDemoBidHistory() {
        // Demo bid history
        val demoHistory = listOf(
            BidHistoryItem("1", "user1", "Ahmed M.", null, 1250.0, System.currentTimeMillis() - 60000, true),
            BidHistoryItem("2", "user2", "Sarah A.", null, 1200.0, System.currentTimeMillis() - 120000, false),
            BidHistoryItem("3", sessionManager.getUserId() ?: "me", "You", null, 1150.0, System.currentTimeMillis() - 180000, false),
            BidHistoryItem("4", "user3", "Omar H.", null, 1100.0, System.currentTimeMillis() - 240000, false),
            BidHistoryItem("5", "user4", "Fatima K.", null, 1050.0, System.currentTimeMillis() - 300000, false)
        )
        bidHistory.clear()
        bidHistory.addAll(demoHistory)
        bidHistoryAdapter.submitList(bidHistory.toList())

        if (bidHistory.isEmpty()) {
            binding.tvNoBids.visibility = View.VISIBLE
            binding.rvBidHistory.visibility = View.GONE
        } else {
            binding.tvNoBids.visibility = View.GONE
            binding.rvBidHistory.visibility = View.VISIBLE
        }
    }

    private fun loadAuctionFromIntent() {
        currentAuctionId = intent.getStringExtra(EXTRA_AUCTION_ID) ?: ""
        val title = intent.getStringExtra(EXTRA_AUCTION_TITLE) ?: "Auction Item"
        val imageUrl = intent.getStringExtra(EXTRA_AUCTION_IMAGE) ?: ""
        val price = intent.getDoubleExtra(EXTRA_AUCTION_PRICE, 0.0)
        val endTime = intent.getLongExtra(EXTRA_AUCTION_END_TIME, System.currentTimeMillis())
        val bidCount = intent.getIntExtra(EXTRA_AUCTION_BID_COUNT, 0)
        val description = intent.getStringExtra(EXTRA_AUCTION_DESCRIPTION) ?: ""
        val realPrice = intent.getDoubleExtra(EXTRA_AUCTION_REAL_PRICE, price * 1.2) // Default to 20% above current
        val marketPrice = intent.getDoubleExtra(EXTRA_AUCTION_MARKET_PRICE, price * 1.5) // Default to 50% above current

        auction = Auction(
            id = currentAuctionId,
            title = title,
            description = description,
            imageUrl = imageUrl,
            currentPrice = price,
            startingPrice = price * 0.9,
            endTime = endTime,
            categoryId = "",
            sellerId = "",
            bidCount = bidCount,
            realPrice = realPrice,
            marketPrice = marketPrice
        )

        // Display auction data
        binding.auctionTitle.text = title
        binding.currentPrice.text = formatPrice(price)
        binding.bidCount.text = getString(R.string.bids_count, bidCount)

        // Display description
        if (description.isNotEmpty()) {
            binding.tvDescription.text = description
        } else {
            binding.tvDescription.text = getString(R.string.no_description)
        }

        // Display real price and market price
        binding.tvRealPrice.text = formatPrice(realPrice)
        binding.tvMarketPrice.text = formatPrice(marketPrice)
        // Apply strikethrough to market price
        binding.tvMarketPrice.paintFlags = binding.tvMarketPrice.paintFlags or Paint.STRIKE_THRU_TEXT_FLAG

        Glide.with(this)
            .load(imageUrl)
            .placeholder(R.drawable.ic_gavel)
            .into(binding.auctionImage)
    }

    private fun setupWebSocket() {
        // Connect to WebSocket
        webSocketManager.connect(sessionManager.getAuthToken())

        // Subscribe to auction updates
        if (currentAuctionId.isNotEmpty()) {
            webSocketManager.subscribeToAuction(currentAuctionId)
        }

        // Listen for bid updates
        lifecycleScope.launch {
            webSocketManager.bidUpdates.collectLatest { update ->
                if (update.auctionId == currentAuctionId) {
                    handleBidUpdate(update)
                }
            }
        }

        // Listen for connection state
        lifecycleScope.launch {
            webSocketManager.connectionState.collectLatest { state ->
                handleConnectionState(state)
            }
        }

        // Listen for auction status updates
        lifecycleScope.launch {
            webSocketManager.auctionUpdates.collectLatest { update ->
                if (update.auctionId == currentAuctionId) {
                    when (update.status) {
                        AuctionStatus.ENDED -> {
                            binding.btnPlaceBid.isEnabled = false
                            binding.btnBuyNow.isEnabled = false
                            Toast.makeText(this@AuctionDetailActivity,
                                getString(R.string.auction_ended), Toast.LENGTH_LONG).show()
                        }
                        AuctionStatus.ENDING_SOON -> {
                            Toast.makeText(this@AuctionDetailActivity,
                                getString(R.string.ending_soon), Toast.LENGTH_SHORT).show()
                        }
                        else -> {}
                    }
                }
            }
        }
    }

    private fun handleBidUpdate(update: BidUpdate) {
        runOnUiThread {
            // Update UI with new bid info
            binding.currentPrice.text = formatPrice(update.currentPrice)
            binding.bidCount.text = "${update.bidCount} bids"

            // Update auction object
            auction = auction?.copy(
                currentPrice = update.currentPrice,
                bidCount = update.bidCount
            )

            // Add to bid history
            val newBid = BidHistoryItem(
                id = UUID.randomUUID().toString(),
                bidderId = update.highestBidder ?: "",
                bidderName = update.highestBidderName ?: "Unknown",
                bidderAvatar = null,
                amount = update.currentPrice,
                timestamp = update.timestamp,
                isWinning = true
            )

            // Mark previous winning bid as not winning
            val updatedHistory = bidHistory.map { it.copy(isWinning = false) }.toMutableList()
            updatedHistory.add(0, newBid)
            bidHistory.clear()
            bidHistory.addAll(updatedHistory)
            bidHistoryAdapter.submitList(bidHistory.toList())

            // Show notification if outbid
            if (!update.isYourBid && sessionManager.isLoggedIn()) {
                binding.tvLiveBidIndicator.visibility = View.VISIBLE
                binding.tvLiveBidIndicator.text = getString(R.string.new_bid_placed)
                handler.postDelayed({
                    binding.tvLiveBidIndicator.visibility = View.GONE
                }, 3000)

                // Show push notification for outbid
                auction?.let { currentAuction ->
                    NotificationHelper.showOutbidNotification(
                        this,
                        currentAuctionId,
                        currentAuction.title,
                        update.currentPrice
                    )
                }
            }

            // Animate price change
            binding.currentPrice.animate()
                .scaleX(1.1f)
                .scaleY(1.1f)
                .setDuration(150)
                .withEndAction {
                    binding.currentPrice.animate()
                        .scaleX(1f)
                        .scaleY(1f)
                        .setDuration(150)
                        .start()
                }
                .start()
        }
    }

    private fun handleConnectionState(state: ConnectionState) {
        runOnUiThread {
            when (state) {
                is ConnectionState.Connected -> {
                    binding.tvConnectionStatus?.text = getString(R.string.live)
                    binding.tvConnectionStatus?.setBackgroundResource(R.drawable.bg_live_indicator)
                }
                is ConnectionState.Disconnected -> {
                    binding.tvConnectionStatus?.text = getString(R.string.offline)
                    binding.tvConnectionStatus?.setBackgroundResource(R.drawable.bg_offline_indicator)
                }
                is ConnectionState.Error -> {
                    binding.tvConnectionStatus?.text = getString(R.string.reconnecting)
                }
            }
        }
    }

    private fun startTimer() {
        timerRunnable = object : Runnable {
            override fun run() {
                auction?.let {
                    binding.timeRemaining.text = it.getTimeRemaining()
                }
                handler.postDelayed(this, 1000)
            }
        }
        handler.post(timerRunnable)
    }

    private fun showBuyNowConfirmation() {
        // Check if user is logged in
        if (!sessionManager.isLoggedIn()) {
            Toast.makeText(this, getString(R.string.please_login_to_buy), Toast.LENGTH_SHORT).show()
            return
        }

        auction?.let { currentAuction ->
            val realPrice = currentAuction.realPrice ?: (currentAuction.currentPrice * 1.2) // Default to 20% above current price
            val formattedPrice = formatPrice(realPrice)

            AlertDialog.Builder(this, R.style.AlertDialogTheme)
                .setTitle(getString(R.string.buy_now_confirmation))
                .setMessage(getString(R.string.buy_now_message, formattedPrice))
                .setPositiveButton(getString(R.string.yes_buy)) { _, _ ->
                    checkNetworkAndProceed {
                        processBuyNow(currentAuction, realPrice)
                    }
                }
                .setNegativeButton(getString(R.string.no_cancel)) { dialog, _ ->
                    dialog.dismiss()
                }
                .show()
        }
    }

    private fun processBuyNow(auction: Auction, realPrice: Double) {
        showLoading(true)
        lifecycleScope.launch {
            try {
                val auctionIdInt = auction.id.toIntOrNull()
                if (auctionIdInt == null || auctionIdInt <= 0) {
                    Toast.makeText(this@AuctionDetailActivity, "Invalid auction ID", Toast.LENGTH_SHORT).show()
                    showLoading(false)
                    return@launch
                }

                val response = ApiClient.apiService.buyNow(auctionIdInt)

                if (response.isSuccessful) {
                    val buyNowResponse = response.body()
                    if (buyNowResponse?.success == true) {
                        Toast.makeText(this@AuctionDetailActivity,
                            buyNowResponse.message ?: "Purchase successful!", Toast.LENGTH_LONG).show()

                        // Navigate to payment activity with purchase details
                        val intent = Intent(this@AuctionDetailActivity, PaymentActivity::class.java).apply {
                            putExtra("auction_id", auction.id)
                            putExtra("auction_title", auction.title)
                            putExtra("product_name", auction.title)
                            putExtra("product_price", buyNowResponse.totalWithFees ?: buyNowResponse.purchasePrice ?: realPrice)
                            putExtra("amount", buyNowResponse.totalWithFees ?: buyNowResponse.purchasePrice ?: realPrice)
                            putExtra("purchase_price", buyNowResponse.purchasePrice)
                            putExtra("total_with_fees", buyNowResponse.totalWithFees)
                            putExtra("is_buy_now", true)
                        }
                        startActivity(intent)

                        // Disable buttons since auction is now ended
                        binding.btnPlaceBid.isEnabled = false
                        binding.btnBuyNow.isEnabled = false

                        // Update auction status
                        this@AuctionDetailActivity.auction = auction.copy(
                            currentPrice = buyNowResponse.purchasePrice ?: realPrice,
                            bidCount = auction.bidCount + 1
                        )
                        binding.currentPrice.text = formatPrice(buyNowResponse.purchasePrice ?: realPrice)

                    } else {
                        val errorMessage = buyNowResponse?.error ?: "Purchase failed"
                        Toast.makeText(this@AuctionDetailActivity, errorMessage, Toast.LENGTH_LONG).show()
                    }
                } else {
                    val errorBody = response.errorBody()?.string()
                    val errorMessage = try {
                        val errorJson = org.json.JSONObject(errorBody ?: "{}")
                        errorJson.optString("error", "Purchase failed")
                    } catch (e: Exception) {
                        "Purchase failed"
                    }
                    Toast.makeText(this@AuctionDetailActivity, errorMessage, Toast.LENGTH_LONG).show()
                }
            } catch (e: java.net.SocketTimeoutException) {
                Toast.makeText(this@AuctionDetailActivity, "Request timeout. Please try again.", Toast.LENGTH_LONG).show()
            } catch (e: java.net.UnknownHostException) {
                Toast.makeText(this@AuctionDetailActivity, getString(R.string.error_network), Toast.LENGTH_LONG).show()
            } catch (e: Exception) {
                android.util.Log.e("AuctionDetailActivity", "Error processing buy now", e)
                Toast.makeText(this@AuctionDetailActivity, "Purchase failed. Please try again.", Toast.LENGTH_LONG).show()
            } finally {
                showLoading(false)
            }
        }
    }

    private fun placeBid() {
        if (!sessionManager.isLoggedIn()) {
            Toast.makeText(this, getString(R.string.please_login_to_bid), Toast.LENGTH_SHORT).show()
            return
        }

        checkNetworkAndProceed {
            placeBidInternal()
        }
    }

    private fun placeBidInternal() {
        // Clear any previous errors
        binding.inputBidAmount.error = null

        val bidAmountText = binding.inputBidAmount.text.toString().trim()
        if (bidAmountText.isEmpty()) {
            binding.inputBidAmount.error = getString(R.string.enter_valid_bid)
            binding.inputBidAmount.requestFocus()
            return
        }

        val bidAmount = try {
            bidAmountText.toDouble()
        } catch (e: NumberFormatException) {
            binding.inputBidAmount.error = getString(R.string.enter_valid_bid)
            binding.inputBidAmount.requestFocus()
            return
        }

        if (bidAmount <= 0) {
            binding.inputBidAmount.error = getString(R.string.enter_valid_bid)
            binding.inputBidAmount.requestFocus()
            return
        }

        auction?.let { currentAuction ->
            // Calculate minimum bid (current price + increment, default increment is 1.0)
            val bidIncrement = 1.0 // Default increment, should come from auction data
            val minimumBid = currentAuction.currentPrice + bidIncrement

            if (bidAmount < minimumBid) {
                binding.inputBidAmount.error = getString(R.string.bid_must_be_higher) + " (Min: ${formatPrice(minimumBid)})"
                binding.inputBidAmount.requestFocus()
                return
            }

            showLoading(true)
            lifecycleScope.launch {
                try {
                    val auctionIdInt = currentAuction.id.toIntOrNull()
                    if (auctionIdInt == null || auctionIdInt <= 0) {
                        Toast.makeText(this@AuctionDetailActivity, "Invalid auction ID", Toast.LENGTH_SHORT).show()
                        showLoading(false)
                        return@launch
                    }

                    val response = ApiClient.apiService.placeBid(
                        auctionIdInt,
                        BidRequest(bidAmount)
                    )

                    if (response.isSuccessful) {
                        val bidResponse = response.body()
                        if (bidResponse?.success == true) {
                            Toast.makeText(this@AuctionDetailActivity,
                                bidResponse.message ?: getString(R.string.bid_placed), Toast.LENGTH_SHORT).show()

                            // Update UI with response data
                            val newCurrentPrice = bidResponse.currentBid ?: bidAmount
                            val newBidCount = currentAuction.bidCount + 1

                            binding.currentPrice.text = formatPrice(newCurrentPrice)
                            binding.bidCount.text = getString(R.string.bids_count, newBidCount)

                            // Update auction object
                            auction = currentAuction.copy(
                                currentPrice = newCurrentPrice,
                                bidCount = newBidCount
                            )

                            // Clear the input field
                            binding.inputBidAmount.text.clear()

                            // Update time if extended
                            if (bidResponse.timeExtended == true && bidResponse.timeLeft != null) {
                                // Update countdown timer with new time
                                updateTimeRemaining(bidResponse.timeLeft)
                            }

                        } else {
                            val errorMessage = bidResponse?.error ?: getString(R.string.error)
                            Toast.makeText(this@AuctionDetailActivity, errorMessage, Toast.LENGTH_LONG).show()
                        }
                    } else {
                        val errorBody = response.errorBody()?.string()
                        val errorMessage = try {
                            val errorJson = org.json.JSONObject(errorBody ?: "{}")
                            errorJson.optString("error", getString(R.string.error))
                        } catch (e: Exception) {
                            getString(R.string.error)
                        }
                        Toast.makeText(this@AuctionDetailActivity, errorMessage, Toast.LENGTH_LONG).show()
                    }
                } catch (e: java.net.SocketTimeoutException) {
                    Toast.makeText(this@AuctionDetailActivity, "Request timeout. Please try again.", Toast.LENGTH_LONG).show()
                } catch (e: java.net.UnknownHostException) {
                    Toast.makeText(this@AuctionDetailActivity, getString(R.string.error_network), Toast.LENGTH_LONG).show()
                } catch (e: Exception) {
                    android.util.Log.e("AuctionDetailActivity", "Error placing bid", e)
                    Toast.makeText(this@AuctionDetailActivity, getString(R.string.error_network), Toast.LENGTH_LONG).show()
                } finally {
                    showLoading(false)
                }
            }
        }
    }

    private fun formatPrice(price: Double): String {
        return NumberFormat.getCurrencyInstance(Locale.US).format(price)
    }

    private fun showLoading(show: Boolean) {
        binding.progressBar.visibility = if (show) View.VISIBLE else View.GONE
        binding.btnPlaceBid.isEnabled = !show
        binding.btnBuyNow.isEnabled = !show
    }

    private fun isNetworkAvailable(): Boolean {
        val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = connectivityManager.activeNetwork ?: return false
        val networkCapabilities = connectivityManager.getNetworkCapabilities(network) ?: return false
        return networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
                networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
    }

    private fun checkNetworkAndProceed(action: () -> Unit) {
        if (!isNetworkAvailable()) {
            Toast.makeText(this, getString(R.string.error_network), Toast.LENGTH_LONG).show()
            return
        }
        action()
    }

    private fun updateTimeRemaining(timeLeftSeconds: Int) {
        val hours = timeLeftSeconds / 3600
        val minutes = (timeLeftSeconds % 3600) / 60
        val seconds = timeLeftSeconds % 60

        val timeText = when {
            hours > 0 -> String.format("%02d:%02d:%02d", hours, minutes, seconds)
            minutes > 0 -> String.format("%02d:%02d", minutes, seconds)
            else -> String.format("00:%02d", seconds)
        }

        binding.timeRemaining.text = timeText
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(timerRunnable)
        // Unsubscribe from auction updates
        if (currentAuctionId.isNotEmpty()) {
            webSocketManager.unsubscribeFromAuction(currentAuctionId)
        }
    }
}

