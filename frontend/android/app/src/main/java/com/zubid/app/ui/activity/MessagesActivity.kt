package com.zubid.app.ui.activity

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import com.zubid.app.data.local.SessionManager
import com.zubid.app.data.websocket.Conversation
import com.zubid.app.databinding.ActivityMessagesBinding
import com.zubid.app.ui.adapter.ConversationsAdapter

class MessagesActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMessagesBinding
    private lateinit var sessionManager: SessionManager
    private lateinit var adapter: ConversationsAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMessagesBinding.inflate(layoutInflater)
        setContentView(binding.root)

        sessionManager = SessionManager(this)

        setupViews()
        loadConversations()
    }

    private fun setupViews() {
        binding.btnBack.setOnClickListener { finish() }

        adapter = ConversationsAdapter { conversation ->
            startActivity(Intent(this, ChatActivity::class.java).apply {
                putExtra("user_id", conversation.participantId)
                putExtra("user_name", conversation.participantName)
                putExtra("user_avatar", conversation.participantAvatar)
            })
        }

        binding.rvConversations.layoutManager = LinearLayoutManager(this)
        binding.rvConversations.adapter = adapter
    }

    private fun loadConversations() {
        // Demo conversations
        val conversations = listOf(
            Conversation(
                id = "1",
                participantId = "user1",
                participantName = "Ahmed Mohammed",
                participantAvatar = null,
                lastMessage = "Is this still available?",
                lastMessageTime = System.currentTimeMillis() - 300_000,
                unreadCount = 2,
                isOnline = true
            ),
            Conversation(
                id = "2",
                participantId = "user2",
                participantName = "Sarah Ali",
                participantAvatar = null,
                lastMessage = "Thank you for your purchase!",
                lastMessageTime = System.currentTimeMillis() - 3600_000,
                unreadCount = 0,
                isOnline = false
            ),
            Conversation(
                id = "3",
                participantId = "user3",
                participantName = "Omar Hassan",
                participantAvatar = null,
                lastMessage = "Can you ship to Erbil?",
                lastMessageTime = System.currentTimeMillis() - 86400_000,
                unreadCount = 1,
                isOnline = true
            )
        )

        if (conversations.isEmpty()) {
            binding.emptyState.visibility = View.VISIBLE
            binding.rvConversations.visibility = View.GONE
        } else {
            binding.emptyState.visibility = View.GONE
            binding.rvConversations.visibility = View.VISIBLE
            adapter.submitList(conversations)
        }
    }

    override fun onResume() {
        super.onResume()
        loadConversations()
    }
}

