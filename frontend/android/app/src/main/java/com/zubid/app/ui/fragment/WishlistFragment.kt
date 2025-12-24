package com.zubid.app.ui.fragment

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.GridLayoutManager
import com.zubid.app.R
import com.zubid.app.data.api.ApiClient
import com.zubid.app.data.local.SessionManager
import com.zubid.app.data.model.Auction
import com.zubid.app.databinding.FragmentWishlistBinding
import com.zubid.app.ui.activity.AuctionDetailActivity
import com.zubid.app.ui.adapter.AuctionAdapter
import kotlinx.coroutines.launch

class WishlistFragment : Fragment() {

    private var _binding: FragmentWishlistBinding? = null
    private val binding get() = _binding!!
    private lateinit var auctionAdapter: AuctionAdapter
    private lateinit var sessionManager: SessionManager
    private var wishlistItems = mutableListOf<Auction>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentWishlistBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        sessionManager = SessionManager(requireContext())
        setupRecyclerView()
        setupSwipeRefresh()
        loadWishlist()
    }

    private fun setupRecyclerView() {
        auctionAdapter = AuctionAdapter(
            onItemClick = { auction ->
                val intent = Intent(requireContext(), AuctionDetailActivity::class.java).apply {
                    putExtra(AuctionDetailActivity.EXTRA_AUCTION_ID, auction.id)
                    putExtra(AuctionDetailActivity.EXTRA_AUCTION_TITLE, auction.title)
                    putExtra(AuctionDetailActivity.EXTRA_AUCTION_IMAGE, auction.imageUrl)
                    putExtra(AuctionDetailActivity.EXTRA_AUCTION_PRICE, auction.currentPrice)
                    putExtra(AuctionDetailActivity.EXTRA_AUCTION_END_TIME, auction.endTime)
                    putExtra(AuctionDetailActivity.EXTRA_AUCTION_BID_COUNT, auction.bidCount)
                    putExtra(AuctionDetailActivity.EXTRA_AUCTION_DESCRIPTION, auction.description)
                }
                startActivity(intent)
            },
            onWishlistClick = { auction ->
                removeFromWishlist(auction)
            }
        )

        binding.wishlistRecyclerView.apply {
            layoutManager = GridLayoutManager(context, 2)
            adapter = auctionAdapter
        }
    }

    private fun setupSwipeRefresh() {
        binding.swipeRefresh.setColorSchemeResources(R.color.coral)
        binding.swipeRefresh.setProgressBackgroundColorSchemeResource(R.color.bg_secondary)
        binding.swipeRefresh.setOnRefreshListener {
            loadWishlist()
        }
    }

    private fun loadWishlist() {
        binding.swipeRefresh.isRefreshing = true

        if (!sessionManager.isLoggedIn()) {
            showEmptyState(emptyList())
            binding.swipeRefresh.isRefreshing = false
            return
        }

        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val response = ApiClient.apiService.getWishlist()
                if (response.isSuccessful && response.body() != null) {
                    wishlistItems = response.body()!!.toMutableList()
                    showEmptyState(wishlistItems)
                } else {
                    showEmptyState(emptyList())
                }
            } catch (e: Exception) {
                e.printStackTrace()
                showEmptyState(emptyList())
            } finally {
                binding.swipeRefresh.isRefreshing = false
            }
        }
    }

    private fun removeFromWishlist(auction: Auction) {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val response = ApiClient.apiService.removeFromWishlist(auction.id.toInt())
                if (response.isSuccessful) {
                    Toast.makeText(context, getString(R.string.removed_from_wishlist), Toast.LENGTH_SHORT).show()
                    wishlistItems.removeAll { it.id == auction.id }
                    showEmptyState(wishlistItems)
                } else {
                    Toast.makeText(context, getString(R.string.error_generic), Toast.LENGTH_SHORT).show()
                }
            } catch (e: Exception) {
                e.printStackTrace()
                Toast.makeText(context, getString(R.string.error_network), Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun showEmptyState(items: List<Auction>) {
        auctionAdapter.submitList(items.toList())
        if (items.isEmpty()) {
            binding.emptyState.visibility = View.VISIBLE
            binding.wishlistRecyclerView.visibility = View.GONE
        } else {
            binding.emptyState.visibility = View.GONE
            binding.wishlistRecyclerView.visibility = View.VISIBLE
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}

