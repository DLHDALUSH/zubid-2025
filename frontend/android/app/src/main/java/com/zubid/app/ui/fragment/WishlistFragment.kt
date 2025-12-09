package com.zubid.app.ui.fragment

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.GridLayoutManager
import com.zubid.app.R
import com.zubid.app.data.model.Auction
import com.zubid.app.databinding.FragmentWishlistBinding
import com.zubid.app.ui.adapter.AuctionAdapter

class WishlistFragment : Fragment() {

    private var _binding: FragmentWishlistBinding? = null
    private val binding get() = _binding!!
    private lateinit var auctionAdapter: AuctionAdapter

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
        setupRecyclerView()
        setupSwipeRefresh()
        loadWishlist()
    }

    private fun setupRecyclerView() {
        auctionAdapter = AuctionAdapter(
            onItemClick = { auction ->
                Toast.makeText(context, "View: ${auction.title}", Toast.LENGTH_SHORT).show()
            },
            onWishlistClick = { auction ->
                Toast.makeText(context, "Removed from wishlist", Toast.LENGTH_SHORT).show()
                // Remove from list and refresh
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
        // Sample data - replace with API call
        val wishlistItems = listOf(
            Auction("4", "Rolex Submariner", "Luxury watch", 
                "https://via.placeholder.com/300", 12500.0, 10000.0, 
                System.currentTimeMillis() + 86400000, "luxury", "seller4", 5, true),
            Auction("5", "Canada Goose Jacket", "Winter coat", 
                "https://via.placeholder.com/300", 850.0, 750.0, 
                System.currentTimeMillis() + 7200000, "winter", "seller5", 12, true)
        )

        auctionAdapter.submitList(wishlistItems)
        binding.swipeRefresh.isRefreshing = false

        // Show/hide empty state
        if (wishlistItems.isEmpty()) {
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

