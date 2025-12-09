package com.zubid.app.ui.activity

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.text.Editable
import android.text.TextWatcher
import android.view.View
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.zubid.app.R
import com.zubid.app.data.local.SessionManager
import com.zubid.app.data.websocket.ChatMessage
import com.zubid.app.data.websocket.MessageReaction
import com.zubid.app.data.websocket.MessageStatus
import com.zubid.app.data.websocket.MessageType
import com.zubid.app.databinding.ActivityChatBinding
import com.zubid.app.ui.adapter.ChatAdapter
import com.zubid.app.util.VoiceRecorderHelper
import java.io.File
import java.util.UUID

class ChatActivity : AppCompatActivity() {

    private lateinit var binding: ActivityChatBinding
    private lateinit var sessionManager: SessionManager
    private lateinit var adapter: ChatAdapter
    private lateinit var voiceRecorder: VoiceRecorderHelper

    private var userId: String = ""
    private var userName: String = ""
    private var userAvatar: String? = null
    private val messages = mutableListOf<ChatMessage>()

    private var currentPhotoUri: Uri? = null
    private val typingHandler = Handler(Looper.getMainLooper())
    private var isTyping = false
    private var otherUserTyping = false
    private var isRecording = false

    // Emoji reactions
    private val reactionEmojis = listOf("👍", "❤️", "😂", "😮", "😢", "👏")

    private val cameraLauncher = registerForActivityResult(
        ActivityResultContracts.TakePicture()
    ) { success ->
        if (success) {
            currentPhotoUri?.let { sendImageMessage(it.toString()) }
        }
    }

    private val galleryLauncher = registerForActivityResult(
        ActivityResultContracts.GetContent()
    ) { uri ->
        uri?.let { sendImageMessage(it.toString()) }
    }

    private val cameraPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        if (isGranted) openCamera()
    }

    private val audioPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        if (isGranted) startVoiceRecording()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityChatBinding.inflate(layoutInflater)
        setContentView(binding.root)

        sessionManager = SessionManager(this)
        voiceRecorder = VoiceRecorderHelper(this)

        userId = intent.getStringExtra("user_id") ?: ""
        userName = intent.getStringExtra("user_name") ?: "User"
        userAvatar = intent.getStringExtra("user_avatar")

        setupViews()
        setupVoiceRecorder()
        loadMessages()
        setupTypingDetection()
        simulateOtherUserTyping()
    }

    private fun setupViews() {
        binding.btnBack.setOnClickListener { finish() }
        binding.tvUserName.text = userName
        binding.tvStatus.text = getString(R.string.online)

        if (!userAvatar.isNullOrEmpty()) {
            Glide.with(this)
                .load(userAvatar)
                .circleCrop()
                .placeholder(R.drawable.ic_person)
                .into(binding.ivAvatar)
        }

        adapter = ChatAdapter(
            currentUserId = sessionManager.getUserId() ?: "",
            onImageClick = { imageUrl ->
                Toast.makeText(this, getString(R.string.view_image), Toast.LENGTH_SHORT).show()
            },
            onMessageLongClick = { message -> showReactionPicker(message) },
            onVoicePlayClick = { voiceUrl -> playVoiceMessage(voiceUrl) }
        )
        binding.rvMessages.layoutManager = LinearLayoutManager(this).apply {
            stackFromEnd = true
        }
        binding.rvMessages.adapter = adapter

        binding.btnSend.setOnClickListener { sendMessage() }
        binding.btnAttach.setOnClickListener { showAttachmentOptions() }
        binding.btnMic.setOnClickListener { toggleVoiceRecording() }
        binding.btnVideoCall.setOnClickListener { startVideoCall() }
    }

    private fun setupVoiceRecorder() {
        voiceRecorder.setDurationCallback { duration ->
            binding.tvRecordingDuration.text = formatDuration(duration)
        }

        voiceRecorder.setAmplitudeCallback { amplitude ->
            // Could update a waveform visualization here
        }
    }

    private fun toggleVoiceRecording() {
        if (isRecording) {
            stopVoiceRecording()
        } else {
            checkAudioPermission()
        }
    }

    private fun checkAudioPermission() {
        when {
            ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
                == PackageManager.PERMISSION_GRANTED -> startVoiceRecording()
            else -> audioPermissionLauncher.launch(Manifest.permission.RECORD_AUDIO)
        }
    }

    private fun startVoiceRecording() {
        if (voiceRecorder.startRecording()) {
            isRecording = true
            binding.recordingLayout.visibility = View.VISIBLE
            binding.inputLayout.visibility = View.GONE
            binding.btnMic.setImageResource(R.drawable.ic_stop)
        } else {
            Toast.makeText(this, getString(R.string.recording_failed), Toast.LENGTH_SHORT).show()
        }
    }

    private fun stopVoiceRecording() {
        val result = voiceRecorder.stopRecording()
        isRecording = false
        binding.recordingLayout.visibility = View.GONE
        binding.inputLayout.visibility = View.VISIBLE
        binding.btnMic.setImageResource(R.drawable.ic_mic)

        result?.let { (file, duration) ->
            if (file != null && duration > 0) {
                sendVoiceMessage(file.absolutePath, duration)
            }
        }
    }

    private fun sendVoiceMessage(voiceUrl: String, duration: Int) {
        val currentUserId = sessionManager.getUserId() ?: "me"
        val newMessage = ChatMessage(
            id = UUID.randomUUID().toString(),
            senderId = currentUserId,
            senderName = "Me",
            senderAvatar = null,
            receiverId = userId,
            message = getString(R.string.voice_message),
            timestamp = System.currentTimeMillis(),
            isFromMe = true,
            status = MessageStatus.SENDING,
            messageType = MessageType.VOICE,
            voiceUrl = voiceUrl,
            voiceDuration = duration
        )

        messages.add(newMessage)
        adapter.submitList(messages.toList())
        binding.rvMessages.scrollToPosition(messages.size - 1)

        // Simulate status updates
        Handler(Looper.getMainLooper()).postDelayed({
            updateMessageStatus(newMessage.id, MessageStatus.SENT)
        }, 1000)

        Handler(Looper.getMainLooper()).postDelayed({
            updateMessageStatus(newMessage.id, MessageStatus.DELIVERED)
        }, 2000)
    }

    private fun playVoiceMessage(voiceUrl: String) {
        voiceRecorder.playAudio(voiceUrl) {
            // Playback complete
        }
    }

    private fun formatDuration(seconds: Int): String {
        val mins = seconds / 60
        val secs = seconds % 60
        return String.format("%d:%02d", mins, secs)
    }

    private fun showReactionPicker(message: ChatMessage) {
        val emojiArray = reactionEmojis.toTypedArray()
        AlertDialog.Builder(this, R.style.AlertDialogTheme)
            .setTitle(getString(R.string.add_reaction))
            .setItems(emojiArray) { _, which ->
                addReactionToMessage(message.id, reactionEmojis[which])
            }
            .show()
    }

    private fun addReactionToMessage(messageId: String, emoji: String) {
        val currentUserId = sessionManager.getUserId() ?: "me"
        val index = messages.indexOfFirst { it.id == messageId }
        if (index >= 0) {
            val message = messages[index]
            val reaction = MessageReaction(
                emoji = emoji,
                userId = currentUserId,
                userName = "Me"
            )
            message.reactions.add(reaction)
            adapter.submitList(messages.toList())
            adapter.notifyItemChanged(index)
        }
    }

    private fun startVideoCall() {
        val intent = VideoCallActivity.newIntent(
            this,
            userId,
            userName,
            userAvatar,
            isOutgoing = true
        )
        startActivity(intent)
    }

    private fun setupTypingDetection() {
        binding.etMessage.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                if (!isTyping && !s.isNullOrEmpty()) {
                    isTyping = true
                    sendTypingIndicator(true)
                }
                typingHandler.removeCallbacksAndMessages(null)
                typingHandler.postDelayed({
                    isTyping = false
                    sendTypingIndicator(false)
                }, 2000)
            }
            override fun afterTextChanged(s: Editable?) {}
        })
    }

    private fun sendTypingIndicator(typing: Boolean) {
        // In real app, send via WebSocket
        // webSocketManager.sendTypingIndicator(userId, typing)
    }

    private fun simulateOtherUserTyping() {
        // Simulate other user typing after 5 seconds
        Handler(Looper.getMainLooper()).postDelayed({
            showTypingIndicator(true)
            Handler(Looper.getMainLooper()).postDelayed({
                showTypingIndicator(false)
                // Simulate receiving a message
                receiveMessage("I'm interested! What's the best price?")
            }, 3000)
        }, 5000)
    }

    private fun showTypingIndicator(show: Boolean) {
        otherUserTyping = show
        binding.typingIndicator.visibility = if (show) View.VISIBLE else View.GONE
        binding.tvTyping.text = getString(R.string.is_typing, userName)
    }

    private fun receiveMessage(text: String) {
        val newMessage = ChatMessage(
            id = UUID.randomUUID().toString(),
            senderId = userId,
            senderName = userName,
            senderAvatar = userAvatar,
            receiverId = sessionManager.getUserId() ?: "me",
            message = text,
            timestamp = System.currentTimeMillis(),
            isFromMe = false,
            status = MessageStatus.DELIVERED
        )
        messages.add(newMessage)
        adapter.submitList(messages.toList())
        binding.rvMessages.scrollToPosition(messages.size - 1)

        // Mark as read after delay
        Handler(Looper.getMainLooper()).postDelayed({
            markMessageAsRead(newMessage.id)
        }, 1000)
    }

    private fun markMessageAsRead(messageId: String) {
        // In real app, send read receipt via WebSocket
        // webSocketManager.sendReadReceipt(messageId)
    }

    private fun showAttachmentOptions() {
        val options = arrayOf(
            getString(R.string.take_picture),
            getString(R.string.choose_from_gallery)
        )
        AlertDialog.Builder(this, R.style.AlertDialogTheme)
            .setTitle(getString(R.string.attach_image))
            .setItems(options) { _, which ->
                when (which) {
                    0 -> checkCameraPermission()
                    1 -> galleryLauncher.launch("image/*")
                }
            }
            .show()
    }

    private fun checkCameraPermission() {
        when {
            ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
                == PackageManager.PERMISSION_GRANTED -> openCamera()
            else -> cameraPermissionLauncher.launch(Manifest.permission.CAMERA)
        }
    }

    private fun openCamera() {
        val photoFile = File(cacheDir, "chat_image_${System.currentTimeMillis()}.jpg")
        currentPhotoUri = FileProvider.getUriForFile(
            this,
            "${packageName}.fileprovider",
            photoFile
        )
        cameraLauncher.launch(currentPhotoUri)
    }

    private fun sendImageMessage(imageUrl: String) {
        val currentUserId = sessionManager.getUserId() ?: "me"
        val newMessage = ChatMessage(
            id = UUID.randomUUID().toString(),
            senderId = currentUserId,
            senderName = "Me",
            senderAvatar = null,
            receiverId = userId,
            message = getString(R.string.image),
            timestamp = System.currentTimeMillis(),
            isFromMe = true,
            status = MessageStatus.SENDING,
            messageType = MessageType.IMAGE,
            imageUrl = imageUrl
        )

        messages.add(newMessage)
        adapter.submitList(messages.toList())
        binding.rvMessages.scrollToPosition(messages.size - 1)

        // Simulate upload and status updates
        Handler(Looper.getMainLooper()).postDelayed({
            updateMessageStatus(newMessage.id, MessageStatus.SENT)
        }, 1000)

        Handler(Looper.getMainLooper()).postDelayed({
            updateMessageStatus(newMessage.id, MessageStatus.DELIVERED)
        }, 2000)

        Handler(Looper.getMainLooper()).postDelayed({
            updateMessageStatus(newMessage.id, MessageStatus.READ)
        }, 4000)

        Toast.makeText(this, getString(R.string.image_sent), Toast.LENGTH_SHORT).show()
    }

    private fun updateMessageStatus(messageId: String, status: MessageStatus) {
        val index = messages.indexOfFirst { it.id == messageId }
        if (index >= 0) {
            messages[index] = messages[index].copy(status = status)
            adapter.submitList(messages.toList())
        }
    }

    private fun loadMessages() {
        val currentUserId = sessionManager.getUserId() ?: "me"
        messages.addAll(listOf(
            ChatMessage(
                id = "1", senderId = userId, senderName = userName, senderAvatar = userAvatar,
                receiverId = currentUserId, message = "Hi! Is this item still available?",
                timestamp = System.currentTimeMillis() - 3600_000, isFromMe = false,
                status = MessageStatus.READ
            ),
            ChatMessage(
                id = "2", senderId = currentUserId, senderName = "Me", senderAvatar = null,
                receiverId = userId, message = "Yes, it's still available!",
                timestamp = System.currentTimeMillis() - 3500_000, isFromMe = true,
                status = MessageStatus.READ
            ),
            ChatMessage(
                id = "3", senderId = userId, senderName = userName, senderAvatar = userAvatar,
                receiverId = currentUserId, message = "Great! Can you ship to Baghdad?",
                timestamp = System.currentTimeMillis() - 3400_000, isFromMe = false,
                status = MessageStatus.READ
            ),
            ChatMessage(
                id = "4", senderId = currentUserId, senderName = "Me", senderAvatar = null,
                receiverId = userId, message = "Yes, shipping is available to all cities in Iraq",
                timestamp = System.currentTimeMillis() - 3300_000, isFromMe = true,
                status = MessageStatus.READ
            )
        ))
        adapter.submitList(messages.toList())
        binding.rvMessages.scrollToPosition(messages.size - 1)
    }

    private fun sendMessage() {
        val text = binding.etMessage.text.toString().trim()
        if (text.isEmpty()) return

        val currentUserId = sessionManager.getUserId() ?: "me"
        val newMessage = ChatMessage(
            id = UUID.randomUUID().toString(),
            senderId = currentUserId,
            senderName = "Me",
            senderAvatar = null,
            receiverId = userId,
            message = text,
            timestamp = System.currentTimeMillis(),
            isFromMe = true,
            status = MessageStatus.SENDING
        )

        messages.add(newMessage)
        adapter.submitList(messages.toList())
        binding.rvMessages.scrollToPosition(messages.size - 1)
        binding.etMessage.text?.clear()

        // Simulate message delivery status updates
        Handler(Looper.getMainLooper()).postDelayed({
            updateMessageStatus(newMessage.id, MessageStatus.SENT)
        }, 500)

        Handler(Looper.getMainLooper()).postDelayed({
            updateMessageStatus(newMessage.id, MessageStatus.DELIVERED)
        }, 1500)

        Handler(Looper.getMainLooper()).postDelayed({
            updateMessageStatus(newMessage.id, MessageStatus.READ)
        }, 3000)

        Toast.makeText(this, getString(R.string.message_sent), Toast.LENGTH_SHORT).show()
    }

    override fun onDestroy() {
        super.onDestroy()
        typingHandler.removeCallbacksAndMessages(null)
        voiceRecorder.release()
    }
}

