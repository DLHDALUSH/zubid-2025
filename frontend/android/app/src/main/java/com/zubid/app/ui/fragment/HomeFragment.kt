package com.zubid.app.ui.fragment

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.GridLayoutManager
import com.zubid.app.R
import com.zubid.app.data.model.Auction
import com.zubid.app.data.model.Category
import com.zubid.app.databinding.FragmentHomeBinding
import com.zubid.app.ui.activity.AuctionDetailActivity
import com.zubid.app.ui.adapter.AuctionAdapter

class HomeFragment : Fragment() {

    private var _binding: FragmentHomeBinding? = null
    private val binding get() = _binding!!

    private lateinit var auctionAdapter: AuctionAdapter
    private val categories = mutableListOf<Category>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentHomeBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupCategoryPills()
        setupAuctionsRecyclerView()
        setupSwipeRefresh()
        loadData()
    }

    private fun setupCategoryPills() {
        categories.addAll(listOf(
            Category("all", "All Products", isSelected = true),
            Category("luxury", "Luxury"),
            Category("winter", "Winter"),
            Category("electronics", "Electronics"),
            Category("fashion", "Fashion"),
            Category("home", "Home")
        ))

        categories.forEach { category ->
            val pill = layoutInflater.inflate(
                R.layout.item_category_pill,
                binding.categoryContainer,
                false
            ) as TextView

            pill.text = category.name
            pill.isSelected = category.isSelected

            pill.setOnClickListener {
                selectCategory(category)
            }

            binding.categoryContainer.addView(pill)
        }
    }

    private fun selectCategory(selected: Category) {
        categories.forEach { it.isSelected = it.id == selected.id }
        
        for (i in 0 until binding.categoryContainer.childCount) {
            val pill = binding.categoryContainer.getChildAt(i) as TextView
            pill.isSelected = categories[i].isSelected
        }
        
        // Filter auctions by category
        Toast.makeText(context, "Selected: ${selected.name}", Toast.LENGTH_SHORT).show()
    }

    private fun setupAuctionsRecyclerView() {
        auctionAdapter = AuctionAdapter(
            onItemClick = { auction ->
                val intent = Intent(requireContext(), AuctionDetailActivity::class.java).apply {
                    putExtra(AuctionDetailActivity.EXTRA_AUCTION_ID, auction.id)
                    putExtra(AuctionDetailActivity.EXTRA_AUCTION_TITLE, auction.title)
                    putExtra(AuctionDetailActivity.EXTRA_AUCTION_IMAGE, auction.imageUrl)
                    putExtra(AuctionDetailActivity.EXTRA_AUCTION_PRICE, auction.currentPrice)
                    putExtra(AuctionDetailActivity.EXTRA_AUCTION_END_TIME, auction.endTime)
                    putExtra(AuctionDetailActivity.EXTRA_AUCTION_BID_COUNT, auction.bidCount)
                }
                startActivity(intent)
            },
            onWishlistClick = { auction ->
                Toast.makeText(context, "Added to wishlist: ${auction.title}", Toast.LENGTH_SHORT).show()
            }
        )

        binding.auctionsRecyclerView.apply {
            layoutManager = GridLayoutManager(context, 2)
            adapter = auctionAdapter
            setHasFixedSize(false)
        }
    }

    private fun setupSwipeRefresh() {
        binding.swipeRefresh.setColorSchemeResources(R.color.coral)
        binding.swipeRefresh.setProgressBackgroundColorSchemeResource(R.color.bg_secondary)
        binding.swipeRefresh.setOnRefreshListener {
            loadData()
        }
    }

    private fun loadData() {
        // Sample data - replace with API call
        val sampleAuctions = listOf(
            Auction("1", "iPhone 15 Pro Max 256GB", "Latest Apple phone", 
                "https://via.placeholder.com/300", 1250.0, 999.0, 
                System.currentTimeMillis() + 9000000, "electronics", "seller1", 15),
            Auction("2", "MacBook Pro M3 14-inch", "Powerful laptop", 
                "https://via.placeholder.com/300", 2100.0, 1999.0, 
                System.currentTimeMillis() + 5400000, "electronics", "seller2", 8),
            Auction("3", "Sony PlayStation 5", "Gaming console", 
                "https://via.placeholder.com/300", 550.0, 499.0, 
                System.currentTimeMillis() + 3600000, "electronics", "seller3", 22),
            Auction("4", "Rolex Submariner", "Luxury watch", 
                "https://via.placeholder.com/300", 12500.0, 10000.0, 
                System.currentTimeMillis() + 86400000, "luxury", "seller4", 5),
            Auction("5", "Canada Goose Jacket", "Winter coat", 
                "https://via.placeholder.com/300", 850.0, 750.0, 
                System.currentTimeMillis() + 7200000, "winter", "seller5", 12),
            Auction("6", "Nike Air Jordan 1", "Limited sneakers", 
                "https://via.placeholder.com/300", 350.0, 250.0, 
                System.currentTimeMillis() + 1800000, "fashion", "seller6", 30)
        )

        auctionAdapter.submitList(sampleAuctions)
        binding.swipeRefresh.isRefreshing = false
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}

