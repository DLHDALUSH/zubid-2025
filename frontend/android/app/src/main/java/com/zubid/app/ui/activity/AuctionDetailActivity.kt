package com.zubid.app.ui.activity

import android.content.Context
import android.content.Intent
import android.graphics.Paint
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
            Toast.makeText(this, "Added to wishlist", Toast.LENGTH_SHORT).show()
        }
        
        binding.btnShare.setOnClickListener {
            Toast.makeText(this, "Share auction", Toast.LENGTH_SHORT).show()
        }
        
        binding.btnPlaceBid.setOnClickListener {
            placeBid()
        }
        
        binding.btnBuyNow.setOnClickListener {
            showBuyNowConfirmation()
        }

        binding.btnContactSeller.setOnClickListener {
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
            val realPrice = currentAuction.realPrice ?: currentAuction.currentPrice
            val formattedPrice = formatPrice(realPrice)

            AlertDialog.Builder(this, R.style.AlertDialogTheme)
                .setTitle(getString(R.string.buy_now_confirmation))
                .setMessage(getString(R.string.buy_now_message, formattedPrice))
                .setPositiveButton(getString(R.string.yes_buy)) { _, _ ->
                    // Navigate to payment activity
                    val intent = Intent(this, PaymentActivity::class.java).apply {
                        putExtra("auction_id", currentAuction.id)
                        putExtra("auction_title", currentAuction.title)
                        putExtra("amount", realPrice)
                    }
                    startActivity(intent)
                }
                .setNegativeButton(getString(R.string.no_cancel)) { dialog, _ ->
                    dialog.dismiss()
                }
                .show()
        }
    }

    private fun placeBid() {
        if (!sessionManager.isLoggedIn()) {
            Toast.makeText(this, getString(R.string.please_login_to_bid), Toast.LENGTH_SHORT).show()
            return
        }

        val bidAmount = binding.inputBidAmount.text.toString().toDoubleOrNull()
        if (bidAmount == null || bidAmount <= 0) {
            Toast.makeText(this, getString(R.string.enter_valid_bid), Toast.LENGTH_SHORT).show()
            return
        }

        auction?.let { currentAuction ->
            if (bidAmount <= currentAuction.currentPrice) {
                Toast.makeText(this, getString(R.string.bid_must_be_higher), Toast.LENGTH_SHORT).show()
                return
            }

            showLoading(true)
            lifecycleScope.launch {
                try {
                    val auctionIdInt = currentAuction.id.toIntOrNull() ?: 0
                    val response = ApiClient.apiService.placeBid(
                        auctionIdInt,
                        BidRequest(bidAmount)
                    )
                    if (response.isSuccessful) {
                        Toast.makeText(this@AuctionDetailActivity, getString(R.string.bid_placed), Toast.LENGTH_SHORT).show()
                        binding.currentPrice.text = formatPrice(bidAmount)
                        // Update auction object
                        auction = currentAuction.copy(currentPrice = bidAmount, bidCount = currentAuction.bidCount + 1)
                        binding.bidCount.text = getString(R.string.bids_count, currentAuction.bidCount + 1)
                    } else {
                        Toast.makeText(this@AuctionDetailActivity, getString(R.string.error), Toast.LENGTH_SHORT).show()
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                    Toast.makeText(this@AuctionDetailActivity, getString(R.string.error_network), Toast.LENGTH_SHORT).show()
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

