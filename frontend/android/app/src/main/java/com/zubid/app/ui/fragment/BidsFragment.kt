package com.zubid.app.ui.fragment

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import com.zubid.app.R
import com.zubid.app.data.api.ApiClient
import com.zubid.app.data.local.SessionManager
import com.zubid.app.data.model.Auction
import com.zubid.app.databinding.FragmentBidsBinding
import com.zubid.app.ui.activity.AuctionDetailActivity
import com.zubid.app.ui.adapter.AuctionAdapter
import kotlinx.coroutines.launch

class BidsFragment : Fragment() {

    private var _binding: FragmentBidsBinding? = null
    private val binding get() = _binding!!
    private lateinit var auctionAdapter: AuctionAdapter
    private lateinit var sessionManager: SessionManager

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
        sessionManager = SessionManager(requireContext())
        setupRecyclerView()
        setupSwipeRefresh()
        loadBids()
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
        binding.swipeRefresh.isRefreshing = true

        if (!sessionManager.isLoggedIn()) {
            showEmptyState(emptyList())
            binding.swipeRefresh.isRefreshing = false
            return
        }

        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val response = ApiClient.apiService.getMyBids()
                if (response.isSuccessful && response.body() != null) {
                    showEmptyState(response.body()!!)
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

    private fun showEmptyState(bids: List<Auction>) {
        auctionAdapter.submitList(bids)
        if (bids.isEmpty()) {
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

