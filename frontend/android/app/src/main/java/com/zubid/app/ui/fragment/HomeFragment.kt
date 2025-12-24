package com.zubid.app.ui.fragment

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.GridLayoutManager
import com.zubid.app.R
import com.zubid.app.data.api.ApiClient
import com.zubid.app.data.model.Auction
import com.zubid.app.data.model.Category
import com.zubid.app.databinding.FragmentHomeBinding
import com.zubid.app.ui.activity.AuctionDetailActivity
import com.zubid.app.ui.adapter.AuctionAdapter
import kotlinx.coroutines.launch

class HomeFragment : Fragment() {

    private var _binding: FragmentHomeBinding? = null
    private val binding get() = _binding!!

    private lateinit var auctionAdapter: AuctionAdapter
    private val categories = mutableListOf<Category>()
    private var currentCategory: String? = null
    private var allAuctions = listOf<Auction>()

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
            Category("all", "All", isSelected = true),
            Category("electronics", "📱 Electronics"),
            Category("luxury", "💎 Luxury"),
            Category("fashion", "👕 Fashion"),
            Category("home", "🏠 Home"),
            Category("winter", "❄️ Winter")
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
        currentCategory = if (selected.id == "all") null else selected.id

        for (i in 0 until binding.categoryContainer.childCount) {
            val pill = binding.categoryContainer.getChildAt(i) as TextView
            pill.isSelected = categories[i].isSelected
        }

        // Filter auctions by category
        filterAuctions()
    }

    private fun filterAuctions() {
        val filtered = if (currentCategory == null) {
            allAuctions
        } else {
            allAuctions.filter { it.categoryId == currentCategory }
        }
        auctionAdapter.submitList(filtered)
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
                    putExtra(AuctionDetailActivity.EXTRA_AUCTION_DESCRIPTION, auction.description)
                }
                startActivity(intent)
            },
            onWishlistClick = { auction ->
                toggleWishlist(auction)
            }
        )

        binding.auctionsRecyclerView.apply {
            layoutManager = GridLayoutManager(context, 2)
            adapter = auctionAdapter
            setHasFixedSize(false)
        }
    }

    private fun toggleWishlist(auction: Auction) {
        val message = if (auction.isWishlisted) {
            getString(R.string.removed_wishlist)
        } else {
            getString(R.string.added_wishlist)
        }
        Toast.makeText(context, "$message: ${auction.title}", Toast.LENGTH_SHORT).show()
    }

    private fun setupSwipeRefresh() {
        binding.swipeRefresh.setColorSchemeResources(R.color.primary)
        binding.swipeRefresh.setProgressBackgroundColorSchemeResource(R.color.bg_card)
        binding.swipeRefresh.setOnRefreshListener {
            loadData()
        }
    }

    private fun loadData() {
        binding.swipeRefresh.isRefreshing = true

        // Try to load from API first, fallback to sample data
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val response = ApiClient.apiService.getAuctions()
                if (response.isSuccessful && response.body() != null) {
                    // Extract auctions from paginated response
                    allAuctions = response.body()!!.auctions
                } else {
                    // Load sample data as fallback
                    loadSampleData()
                }
            } catch (e: Exception) {
                // Network error - load sample data
                e.printStackTrace()
                loadSampleData()
            } finally {
                filterAuctions()
                binding.swipeRefresh.isRefreshing = false
            }
        }
    }

    private fun loadSampleData() {
        allAuctions = listOf(
            Auction("1", "iPhone 15 Pro Max 256GB", "Latest Apple flagship phone with A17 Pro chip, titanium design, and advanced camera system.",
                "https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=400", 1250.0, 999.0,
                System.currentTimeMillis() + 9000000, "electronics", "seller1", 15),
            Auction("2", "MacBook Pro M3 14-inch", "Powerful laptop with M3 chip, stunning Liquid Retina XDR display.",
                "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400", 2100.0, 1999.0,
                System.currentTimeMillis() + 5400000, "electronics", "seller2", 8),
            Auction("3", "Sony PlayStation 5", "Next-gen gaming console with ultra-high speed SSD and 3D audio.",
                "https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=400", 550.0, 499.0,
                System.currentTimeMillis() + 3600000, "electronics", "seller3", 22),
            Auction("4", "Rolex Submariner", "Iconic luxury dive watch, 41mm, black dial, Oystersteel.",
                "https://images.unsplash.com/photo-1523170335258-f5ed11844a49?w=400", 12500.0, 10000.0,
                System.currentTimeMillis() + 86400000, "luxury", "seller4", 5),
            Auction("5", "Canada Goose Expedition Parka", "Premium winter coat for extreme cold weather protection.",
                "https://images.unsplash.com/photo-1544923246-77307dd628b4?w=400", 850.0, 750.0,
                System.currentTimeMillis() + 7200000, "winter", "seller5", 12),
            Auction("6", "Nike Air Jordan 1 Retro High OG", "Limited edition sneakers, Chicago colorway.",
                "https://images.unsplash.com/photo-1556906781-9a412961c28c?w=400", 350.0, 250.0,
                System.currentTimeMillis() + 1800000, "fashion", "seller6", 30),
            Auction("7", "Samsung 65\" 4K OLED TV", "Premium OLED display with stunning colors and contrast.",
                "https://images.unsplash.com/photo-1593784991095-a205069470b6?w=400", 1800.0, 1500.0,
                System.currentTimeMillis() + 10800000, "electronics", "seller7", 18),
            Auction("8", "Gucci GG Marmont Bag", "Luxury leather handbag with signature GG hardware.",
                "https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=400", 2200.0, 1800.0,
                System.currentTimeMillis() + 14400000, "luxury", "seller8", 9)
        )
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}

