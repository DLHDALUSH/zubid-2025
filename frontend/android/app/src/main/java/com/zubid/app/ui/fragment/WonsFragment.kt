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
import com.zubid.app.databinding.FragmentWonsBinding
import com.zubid.app.ui.adapter.AuctionAdapter

class WonsFragment : Fragment() {

    private var _binding: FragmentWonsBinding? = null
    private val binding get() = _binding!!
    private lateinit var auctionAdapter: AuctionAdapter

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentWonsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupRecyclerView()
        setupSwipeRefresh()
        loadWons()
    }

    private fun setupRecyclerView() {
        auctionAdapter = AuctionAdapter(
            onItemClick = { auction ->
                Toast.makeText(context, "View won item: ${auction.title}", Toast.LENGTH_SHORT).show()
            },
            onWishlistClick = { auction ->
                // Do nothing for won items
            }
        )

        binding.wonsRecyclerView.apply {
            layoutManager = LinearLayoutManager(context)
            adapter = auctionAdapter
        }
    }

    private fun setupSwipeRefresh() {
        binding.swipeRefresh.setColorSchemeResources(R.color.coral)
        binding.swipeRefresh.setProgressBackgroundColorSchemeResource(R.color.bg_secondary)
        binding.swipeRefresh.setOnRefreshListener {
            loadWons()
        }
    }

    private fun loadWons() {
        // Sample data - replace with API call
        val wonItems = listOf(
            Auction("10", "Apple AirPods Pro", "Won for $180", 
                "https://via.placeholder.com/300", 180.0, 150.0, 
                System.currentTimeMillis() - 86400000, "electronics", "seller1", 8),
            Auction("11", "Nintendo Switch OLED", "Won for $320", 
                "https://via.placeholder.com/300", 320.0, 280.0, 
                System.currentTimeMillis() - 172800000, "electronics", "seller2", 12)
        )

        auctionAdapter.submitList(wonItems)
        binding.swipeRefresh.isRefreshing = false

        // Show/hide empty state
        if (wonItems.isEmpty()) {
            binding.emptyState.visibility = View.VISIBLE
            binding.wonsRecyclerView.visibility = View.GONE
        } else {
            binding.emptyState.visibility = View.GONE
            binding.wonsRecyclerView.visibility = View.VISIBLE
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}

