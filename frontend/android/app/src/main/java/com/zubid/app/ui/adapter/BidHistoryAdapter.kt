package com.zubid.app.ui.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.zubid.app.R
import com.zubid.app.data.websocket.BidHistoryItem
import java.text.SimpleDateFormat
import java.util.*

class BidHistoryAdapter(
    private val currentUserId: String?
) : ListAdapter<BidHistoryItem, BidHistoryAdapter.BidViewHolder>(BidDiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BidViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_bid_history, parent, false)
        return BidViewHolder(view)
    }

    override fun onBindViewHolder(holder: BidViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class BidViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val ivAvatar: ImageView = itemView.findViewById(R.id.ivBidderAvatar)
        private val tvName: TextView = itemView.findViewById(R.id.tvBidderName)
        private val tvAmount: TextView = itemView.findViewById(R.id.tvBidAmount)
        private val tvTime: TextView = itemView.findViewById(R.id.tvBidTime)
        private val tvWinning: TextView = itemView.findViewById(R.id.tvWinningBadge)
        private val tvYourBid: TextView = itemView.findViewById(R.id.tvYourBidBadge)

        fun bind(bid: BidHistoryItem) {
            tvName.text = bid.bidderName
            tvAmount.text = String.format("$%.2f", bid.amount)
            tvTime.text = formatTime(bid.timestamp)

            // Avatar
            if (!bid.bidderAvatar.isNullOrEmpty()) {
                Glide.with(itemView.context)
                    .load(bid.bidderAvatar)
                    .circleCrop()
                    .placeholder(R.drawable.ic_person)
                    .into(ivAvatar)
            } else {
                ivAvatar.setImageResource(R.drawable.ic_person)
            }

            // Badges
            tvWinning.visibility = if (bid.isWinning) View.VISIBLE else View.GONE
            tvYourBid.visibility = if (bid.bidderId == currentUserId) View.VISIBLE else View.GONE

            // Highlight winning bid
            if (bid.isWinning) {
                tvAmount.setTextColor(itemView.context.getColor(R.color.coral))
            } else {
                tvAmount.setTextColor(itemView.context.getColor(R.color.white))
            }
        }

        private fun formatTime(timestamp: Long): String {
            val now = System.currentTimeMillis()
            val diff = now - timestamp
            
            return when {
                diff < 60_000 -> "Just now"
                diff < 3600_000 -> "${diff / 60_000}m ago"
                diff < 86400_000 -> "${diff / 3600_000}h ago"
                else -> {
                    val sdf = SimpleDateFormat("MMM d, HH:mm", Locale.getDefault())
                    sdf.format(Date(timestamp))
                }
            }
        }
    }

    class BidDiffCallback : DiffUtil.ItemCallback<BidHistoryItem>() {
        override fun areItemsTheSame(oldItem: BidHistoryItem, newItem: BidHistoryItem): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: BidHistoryItem, newItem: BidHistoryItem): Boolean {
            return oldItem == newItem
        }
    }
}

