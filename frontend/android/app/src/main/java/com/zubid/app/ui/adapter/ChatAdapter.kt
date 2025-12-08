package com.zubid.app.ui.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.zubid.app.R
import com.zubid.app.data.websocket.ChatMessage
import com.zubid.app.data.websocket.MessageStatus
import com.zubid.app.data.websocket.MessageType
import java.text.SimpleDateFormat
import java.util.*

class ChatAdapter(
    private val currentUserId: String,
    private val onImageClick: ((String) -> Unit)? = null,
    private val onMessageLongClick: ((ChatMessage) -> Unit)? = null,
    private val onVoicePlayClick: ((String) -> Unit)? = null
) : ListAdapter<ChatMessage, RecyclerView.ViewHolder>(MessageDiffCallback()) {

    companion object {
        private const val VIEW_TYPE_SENT = 1
        private const val VIEW_TYPE_RECEIVED = 2
    }

    override fun getItemViewType(position: Int): Int {
        return if (getItem(position).isFromMe) VIEW_TYPE_SENT else VIEW_TYPE_RECEIVED
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            VIEW_TYPE_SENT -> {
                val view = LayoutInflater.from(parent.context)
                    .inflate(R.layout.item_message_sent, parent, false)
                SentMessageViewHolder(view)
            }
            else -> {
                val view = LayoutInflater.from(parent.context)
                    .inflate(R.layout.item_message_received, parent, false)
                ReceivedMessageViewHolder(view)
            }
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val message = getItem(position)
        when (holder) {
            is SentMessageViewHolder -> holder.bind(message)
            is ReceivedMessageViewHolder -> holder.bind(message)
        }
    }

    inner class SentMessageViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val tvMessage: TextView = itemView.findViewById(R.id.tvMessage)
        private val tvTime: TextView = itemView.findViewById(R.id.tvTime)
        private val tvStatus: TextView? = itemView.findViewById(R.id.tvStatus)
        private val ivImage: ImageView? = itemView.findViewById(R.id.ivImage)
        private val voiceLayout: LinearLayout? = itemView.findViewById(R.id.voiceLayout)
        private val btnPlayVoice: ImageButton? = itemView.findViewById(R.id.btnPlayVoice)
        private val tvVoiceDuration: TextView? = itemView.findViewById(R.id.tvVoiceDuration)
        private val tvReactions: TextView? = itemView.findViewById(R.id.tvReactions)

        fun bind(message: ChatMessage) {
            val context = itemView.context

            // Reset all views
            tvMessage.visibility = View.GONE
            ivImage?.visibility = View.GONE
            voiceLayout?.visibility = View.GONE

            // Handle message type
            when (message.messageType) {
                MessageType.IMAGE -> {
                    if (!message.imageUrl.isNullOrEmpty()) {
                        ivImage?.visibility = View.VISIBLE
                        ivImage?.let { iv ->
                            Glide.with(context)
                                .load(message.imageUrl)
                                .centerCrop()
                                .placeholder(R.drawable.ic_image_placeholder)
                                .into(iv)
                            iv.setOnClickListener { onImageClick?.invoke(message.imageUrl) }
                        }
                    }
                }
                MessageType.VOICE -> {
                    voiceLayout?.visibility = View.VISIBLE
                    tvVoiceDuration?.text = formatVoiceDuration(message.voiceDuration)
                    btnPlayVoice?.setOnClickListener {
                        message.voiceUrl?.let { url -> onVoicePlayClick?.invoke(url) }
                    }
                }
                else -> {
                    tvMessage.visibility = View.VISIBLE
                    tvMessage.text = message.message
                }
            }

            tvTime.text = formatTime(message.timestamp)

            // Show reactions
            if (message.reactions.isNotEmpty()) {
                tvReactions?.visibility = View.VISIBLE
                tvReactions?.text = message.reactions.joinToString(" ") { it.emoji }
            } else {
                tvReactions?.visibility = View.GONE
            }

            // Long click for reactions
            itemView.setOnLongClickListener {
                onMessageLongClick?.invoke(message)
                true
            }

            // Show read receipt status
            tvStatus?.let { status ->
                status.visibility = View.VISIBLE
                when (message.status) {
                    MessageStatus.SENDING -> {
                        status.text = context.getString(R.string.sending)
                        status.setTextColor(context.getColor(R.color.text_muted))
                    }
                    MessageStatus.SENT -> {
                        status.text = "✓"
                        status.setTextColor(context.getColor(R.color.text_muted))
                    }
                    MessageStatus.DELIVERED -> {
                        status.text = "✓✓"
                        status.setTextColor(context.getColor(R.color.text_muted))
                    }
                    MessageStatus.READ -> {
                        status.text = "✓✓"
                        status.setTextColor(context.getColor(R.color.primary))
                    }
                    MessageStatus.FAILED -> {
                        status.text = context.getString(R.string.failed_to_send)
                        status.setTextColor(context.getColor(R.color.error))
                    }
                }
            }
        }
    }

    inner class ReceivedMessageViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val tvMessage: TextView = itemView.findViewById(R.id.tvMessage)
        private val tvTime: TextView = itemView.findViewById(R.id.tvTime)
        private val ivImage: ImageView? = itemView.findViewById(R.id.ivImage)
        private val voiceLayout: LinearLayout? = itemView.findViewById(R.id.voiceLayout)
        private val btnPlayVoice: ImageButton? = itemView.findViewById(R.id.btnPlayVoice)
        private val tvVoiceDuration: TextView? = itemView.findViewById(R.id.tvVoiceDuration)
        private val tvReactions: TextView? = itemView.findViewById(R.id.tvReactions)

        fun bind(message: ChatMessage) {
            val context = itemView.context

            // Reset all views
            tvMessage.visibility = View.GONE
            ivImage?.visibility = View.GONE
            voiceLayout?.visibility = View.GONE

            // Handle message type
            when (message.messageType) {
                MessageType.IMAGE -> {
                    if (!message.imageUrl.isNullOrEmpty()) {
                        ivImage?.visibility = View.VISIBLE
                        ivImage?.let { iv ->
                            Glide.with(context)
                                .load(message.imageUrl)
                                .centerCrop()
                                .placeholder(R.drawable.ic_image_placeholder)
                                .into(iv)
                            iv.setOnClickListener { onImageClick?.invoke(message.imageUrl) }
                        }
                    }
                }
                MessageType.VOICE -> {
                    voiceLayout?.visibility = View.VISIBLE
                    tvVoiceDuration?.text = formatVoiceDuration(message.voiceDuration)
                    btnPlayVoice?.setOnClickListener {
                        message.voiceUrl?.let { url -> onVoicePlayClick?.invoke(url) }
                    }
                }
                else -> {
                    tvMessage.visibility = View.VISIBLE
                    tvMessage.text = message.message
                }
            }

            tvTime.text = formatTime(message.timestamp)

            // Show reactions
            if (message.reactions.isNotEmpty()) {
                tvReactions?.visibility = View.VISIBLE
                tvReactions?.text = message.reactions.joinToString(" ") { it.emoji }
            } else {
                tvReactions?.visibility = View.GONE
            }

            // Long click for reactions
            itemView.setOnLongClickListener {
                onMessageLongClick?.invoke(message)
                true
            }
        }
    }

    private fun formatTime(timestamp: Long): String {
        return SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date(timestamp))
    }

    private fun formatVoiceDuration(seconds: Int): String {
        val mins = seconds / 60
        val secs = seconds % 60
        return String.format("%d:%02d", mins, secs)
    }

    class MessageDiffCallback : DiffUtil.ItemCallback<ChatMessage>() {
        override fun areItemsTheSame(oldItem: ChatMessage, newItem: ChatMessage): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: ChatMessage, newItem: ChatMessage): Boolean {
            return oldItem == newItem
        }
    }
}

