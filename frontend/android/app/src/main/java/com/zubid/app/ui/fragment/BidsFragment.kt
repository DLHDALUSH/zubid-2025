package com.zubid.app.ui.fragment

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import com.zubid.app.R
import com.zubid.app.data.model.Auction
import com.zubid.app.databinding.FragmentBidsBinding
import com.zubid.app.ui.adapter.AuctionAdapter

class BidsFragment : Fragment() {

    private var _binding: FragmentBidsBinding? = null
    private val binding get() = _binding!!
    private lateinit var auctionAdapter: AuctionAdapter

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentBidsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupRecyclerView()
        setupSwipeRefresh()
        loadBids()
    }

    private fun setupRecyclerView() {
        auctionAdapter = AuctionAdapter(
            onItemClick = { auction ->
                Toast.makeText(context, "View bid: ${auction.title}", Toast.LENGTH_SHORT).show()
            },
            onWishlistClick = { auction ->
                Toast.makeText(context, "Wishlist: ${auction.title}", Toast.LENGTH_SHORT).show()
            }
        )

        binding.bidsRecyclerView.apply {
            layoutManager = LinearLayoutManager(context)
            adapter = auctionAdapter
        }
    }

    private fun setupSwipeRefresh() {
        binding.swipeRefresh.setColorSchemeResources(R.color.coral)
        binding.swipeRefresh.setProgressBackgroundColorSchemeResource(R.color.bg_secondary)
        binding.swipeRefresh.setOnRefreshListener {
            loadBids()
        }
    }

    private fun loadBids() {
        // Sample data - replace with API call
        val myBids = listOf(
            Auction("1", "iPhone 15 Pro Max 256GB", "Your bid: $1,250", 
                "https://via.placeholder.com/300", 1250.0, 999.0, 
                System.currentTimeMillis() + 9000000, "electronics", "seller1", 15),
            Auction("2", "MacBook Pro M3 14-inch", "Your bid: $2,100", 
                "https://via.placeholder.com/300", 2100.0, 1999.0, 
                System.currentTimeMillis() + 5400000, "electronics", "seller2", 8),
            Auction("3", "Sony PlayStation 5", "Your bid: $550", 
                "https://via.placeholder.com/300", 550.0, 499.0, 
                System.currentTimeMillis() + 3600000, "electronics", "seller3", 22)
        )

        auctionAdapter.submitList(myBids)
        binding.swipeRefresh.isRefreshing = false

        // Show/hide empty state
        if (myBids.isEmpty()) {
            binding.emptyState.visibility = View.VISIBLE
            binding.bidsRecyclerView.visibility = View.GONE
        } else {
            binding.emptyState.visibility = View.GONE
            binding.bidsRecyclerView.visibility = View.VISIBLE
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}

