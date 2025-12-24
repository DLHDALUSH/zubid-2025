package com.zubid.app.data.model

import com.google.gson.annotations.SerializedName

data class Auction(
    val id: String,
    val title: String,
    val description: String,
    val imageUrl: String?,
    val currentPrice: Double,
    val startingPrice: Double,
    val endTime: Long,
    val categoryId: String,
    val sellerId: String,
    val bidCount: Int = 0,
    val isWishlisted: Boolean = false,
    val realPrice: Double? = null,
    val marketPrice: Double? = null
) {
    fun getTimeRemaining(): String {
        val now = System.currentTimeMillis()
        val diff = endTime - now

        if (diff <= 0) return "Ended"

        val hours = diff / (1000 * 60 * 60)
        val minutes = (diff % (1000 * 60 * 60)) / (1000 * 60)
        val seconds = (diff % (1000 * 60)) / 1000

        return String.format("%02dh %02dm %02ds", hours, minutes, seconds)
    }

    fun getFormattedPrice(): String {
        return "$${String.format("%.0f", currentPrice)}"
    }
}

// Response wrapper for paginated auctions from /api/auctions endpoint
data class AuctionsResponse(
    val auctions: List<Auction>,
    val total: Int,
    val page: Int,
    @SerializedName("per_page")
    val perPage: Int,
    val pages: Int
)

