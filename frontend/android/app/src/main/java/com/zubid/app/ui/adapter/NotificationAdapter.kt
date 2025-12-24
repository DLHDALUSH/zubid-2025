package com.zubid.app.ui.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.zubid.app.R
import com.zubid.app.data.model.Notification
import com.zubid.app.databinding.ItemNotificationBinding

class NotificationAdapter(
    private val onItemClick: (Notification) -> Unit
) : ListAdapter<Notification, NotificationAdapter.NotificationViewHolder>(NotificationDiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): NotificationViewHolder {
        val binding = ItemNotificationBinding.inflate(
            LayoutInflater.from(parent.context), parent, false
        )
        return NotificationViewHolder(binding)
    }

    override fun onBindViewHolder(holder: NotificationViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class NotificationViewHolder(
        private val binding: ItemNotificationBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        init {
            binding.root.setOnClickListener {
                val position = bindingAdapterPosition
                if (position != RecyclerView.NO_POSITION) {
                    onItemClick(getItem(position))
                }
            }
        }

        fun bind(notification: Notification) {
            binding.notificationTitle.text = notification.title
            binding.notificationMessage.text = notification.message
            binding.notificationTime.text = notification.getTimeAgo()

            // Set icon based on type
            val iconRes = when (notification.type) {
                "outbid" -> R.drawable.ic_gavel
                "ending" -> R.drawable.ic_timer
                "won" -> R.drawable.ic_trophy
                "new" -> R.drawable.ic_bell
                else -> R.drawable.ic_bell
            }
            binding.notificationIcon.setImageResource(iconRes)

            // Set background based on read status
            val bgAlpha = if (notification.isRead) 0.5f else 1.0f
            binding.root.alpha = bgAlpha
        }
    }

    class NotificationDiffCallback : DiffUtil.ItemCallback<Notification>() {
        override fun areItemsTheSame(oldItem: Notification, newItem: Notification): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: Notification, newItem: Notification): Boolean {
            return oldItem == newItem
        }
    }
}

