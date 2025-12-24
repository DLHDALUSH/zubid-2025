package com.zubid.app.ui.adapter

import android.os.Handler
import android.os.Looper
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.zubid.app.R
import com.zubid.app.data.model.Auction
import com.zubid.app.databinding.ItemAuctionBinding

class AuctionAdapter(
    private val onItemClick: (Auction) -> Unit,
    private val onWishlistClick: (Auction) -> Unit
) : ListAdapter<Auction, AuctionAdapter.AuctionViewHolder>(AuctionDiffCallback()) {

    private val handler = Handler(Looper.getMainLooper())
    private val updateRunnable = object : Runnable {
        override fun run() {
            notifyItemRangeChanged(0, itemCount, PAYLOAD_TIMER)
            handler.postDelayed(this, 1000)
        }
    }

    override fun onAttachedToRecyclerView(recyclerView: RecyclerView) {
        super.onAttachedToRecyclerView(recyclerView)
        handler.post(updateRunnable)
    }

    override fun onDetachedFromRecyclerView(recyclerView: RecyclerView) {
        super.onDetachedFromRecyclerView(recyclerView)
        handler.removeCallbacks(updateRunnable)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): AuctionViewHolder {
        val binding = ItemAuctionBinding.inflate(
            LayoutInflater.from(parent.context), parent, false
        )
        return AuctionViewHolder(binding)
    }

    override fun onBindViewHolder(holder: AuctionViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    override fun onBindViewHolder(holder: AuctionViewHolder, position: Int, payloads: MutableList<Any>) {
        if (payloads.contains(PAYLOAD_TIMER)) {
            holder.updateTimer(getItem(position))
        } else {
            super.onBindViewHolder(holder, position, payloads)
        }
    }

    inner class AuctionViewHolder(
        private val binding: ItemAuctionBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        init {
            binding.root.setOnClickListener {
                val position = bindingAdapterPosition
                if (position != RecyclerView.NO_POSITION) {
                    onItemClick(getItem(position))
                }
            }
            binding.wishlistBtn.setOnClickListener {
                val position = bindingAdapterPosition
                if (position != RecyclerView.NO_POSITION) {
                    onWishlistClick(getItem(position))
                }
            }
        }

        fun bind(auction: Auction) {
            binding.auctionTitle.text = auction.title
            binding.priceBadge.text = auction.getFormattedPrice()
            updateTimer(auction)

            // Load image with Glide
            if (!auction.imageUrl.isNullOrEmpty()) {
                Glide.with(binding.auctionImage)
                    .load(auction.imageUrl)
                    .placeholder(R.drawable.ic_launcher_foreground)
                    .error(R.drawable.ic_launcher_foreground)
                    .centerCrop()
                    .into(binding.auctionImage)
            }

            // Update wishlist icon
            val heartIcon = if (auction.isWishlisted) {
                R.drawable.ic_heart
            } else {
                R.drawable.ic_heart_outline
            }
            binding.wishlistBtn.setImageResource(heartIcon)
        }

        fun updateTimer(auction: Auction) {
            binding.timerBadge.text = auction.getTimeRemaining()
        }
    }

    class AuctionDiffCallback : DiffUtil.ItemCallback<Auction>() {
        override fun areItemsTheSame(oldItem: Auction, newItem: Auction): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: Auction, newItem: Auction): Boolean {
            return oldItem == newItem
        }
    }

    companion object {
        private const val PAYLOAD_TIMER = "payload_timer"
    }
}

