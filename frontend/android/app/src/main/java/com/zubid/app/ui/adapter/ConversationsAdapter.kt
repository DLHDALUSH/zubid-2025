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
import com.zubid.app.data.websocket.Conversation
import java.text.SimpleDateFormat
import java.util.*

class ConversationsAdapter(
    private val onClick: (Conversation) -> Unit
) : ListAdapter<Conversation, ConversationsAdapter.ConversationViewHolder>(ConversationDiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ConversationViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_conversation, parent, false)
        return ConversationViewHolder(view)
    }

    override fun onBindViewHolder(holder: ConversationViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class ConversationViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val ivAvatar: ImageView = itemView.findViewById(R.id.ivAvatar)
        private val tvName: TextView = itemView.findViewById(R.id.tvName)
        private val tvMessage: TextView = itemView.findViewById(R.id.tvLastMessage)
        private val tvTime: TextView = itemView.findViewById(R.id.tvTime)
        private val tvUnread: TextView = itemView.findViewById(R.id.tvUnreadCount)
        private val onlineIndicator: View = itemView.findViewById(R.id.onlineIndicator)

        fun bind(conversation: Conversation) {
            tvName.text = conversation.participantName
            tvMessage.text = conversation.lastMessage
            tvTime.text = formatTime(conversation.lastMessageTime)

            // Avatar
            if (!conversation.participantAvatar.isNullOrEmpty()) {
                Glide.with(itemView.context)
                    .load(conversation.participantAvatar)
                    .circleCrop()
                    .placeholder(R.drawable.ic_person)
                    .into(ivAvatar)
            } else {
                ivAvatar.setImageResource(R.drawable.ic_person)
            }

            // Online indicator
            onlineIndicator.visibility = if (conversation.isOnline) View.VISIBLE else View.GONE

            // Unread count
            if (conversation.unreadCount > 0) {
                tvUnread.visibility = View.VISIBLE
                tvUnread.text = conversation.unreadCount.toString()
                tvMessage.setTextColor(itemView.context.getColor(R.color.white))
            } else {
                tvUnread.visibility = View.GONE
                tvMessage.setTextColor(itemView.context.getColor(R.color.text_muted))
            }

            itemView.setOnClickListener { onClick(conversation) }
        }

        private fun formatTime(timestamp: Long): String {
            val now = System.currentTimeMillis()
            val diff = now - timestamp
            val cal = Calendar.getInstance()
            val todayStart = cal.apply { 
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
            }.timeInMillis
            
            return when {
                diff < 60_000 -> "Now"
                diff < 3600_000 -> "${diff / 60_000}m"
                timestamp >= todayStart -> {
                    SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date(timestamp))
                }
                timestamp >= todayStart - 86400_000 -> itemView.context.getString(R.string.yesterday)
                else -> SimpleDateFormat("MMM d", Locale.getDefault()).format(Date(timestamp))
            }
        }
    }

    class ConversationDiffCallback : DiffUtil.ItemCallback<Conversation>() {
        override fun areItemsTheSame(oldItem: Conversation, newItem: Conversation): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: Conversation, newItem: Conversation): Boolean {
            return oldItem == newItem
        }
    }
}

