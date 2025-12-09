package com.zubid.app.data.websocket

import com.google.gson.annotations.SerializedName

sealed class ConnectionState {
    object Connected : ConnectionState()
    object Disconnected : ConnectionState()
    data class Error(val message: String) : ConnectionState()
}

data class BidUpdate(
    @SerializedName("type")
    val type: String = "bid_update",

    @SerializedName("auctionId")
    val auctionId: String,

    @SerializedName("currentPrice")
    val currentPrice: Double,

    @SerializedName("bidCount")
    val bidCount: Int,

    @SerializedName("highestBidder")
    val highestBidder: String?,

    @SerializedName("highestBidderName")
    val highestBidderName: String? = null,

    @SerializedName("isYourBid")
    val isYourBid: Boolean = false,

    @SerializedName("timestamp")
    val timestamp: Long = System.currentTimeMillis()
)

data class AuctionUpdate(
    @SerializedName("type")
    val type: String = "auction_update",
    
    @SerializedName("auctionId")
    val auctionId: String,
    
    @SerializedName("status")
    val status: AuctionStatus,
    
    @SerializedName("endTime")
    val endTime: Long?,
    
    @SerializedName("winner")
    val winner: String?,
    
    @SerializedName("finalPrice")
    val finalPrice: Double?
)

enum class AuctionStatus {
    @SerializedName("live")
    LIVE,
    
    @SerializedName("ending_soon")
    ENDING_SOON,
    
    @SerializedName("ended")
    ENDED,
    
    @SerializedName("cancelled")
    CANCELLED
}

data class OutbidNotification(
    @SerializedName("auctionId")
    val auctionId: String,
    
    @SerializedName("auctionTitle")
    val auctionTitle: String,
    
    @SerializedName("currentPrice")
    val currentPrice: Double,
    
    @SerializedName("yourBid")
    val yourBid: Double
)

data class WinNotification(
    @SerializedName("auctionId")
    val auctionId: String,

    @SerializedName("auctionTitle")
    val auctionTitle: String,

    @SerializedName("finalPrice")
    val finalPrice: Double
)

// Bid History Models
data class BidHistoryItem(
    @SerializedName("id")
    val id: String,

    @SerializedName("bidderId")
    val bidderId: String,

    @SerializedName("bidderName")
    val bidderName: String,

    @SerializedName("bidderAvatar")
    val bidderAvatar: String?,

    @SerializedName("amount")
    val amount: Double,

    @SerializedName("timestamp")
    val timestamp: Long,

    @SerializedName("isWinning")
    val isWinning: Boolean = false
)

data class BidHistoryResponse(
    @SerializedName("auctionId")
    val auctionId: String,

    @SerializedName("bids")
    val bids: List<BidHistoryItem>,

    @SerializedName("totalBids")
    val totalBids: Int
)

// Message Status
enum class MessageStatus {
    @SerializedName("sending")
    SENDING,

    @SerializedName("sent")
    SENT,

    @SerializedName("delivered")
    DELIVERED,

    @SerializedName("read")
    READ,

    @SerializedName("failed")
    FAILED
}

// Message Type
enum class MessageType {
    @SerializedName("text")
    TEXT,

    @SerializedName("image")
    IMAGE,

    @SerializedName("voice")
    VOICE,

    @SerializedName("video_call")
    VIDEO_CALL
}

// Message Reaction
data class MessageReaction(
    @SerializedName("emoji")
    val emoji: String,

    @SerializedName("userId")
    val userId: String,

    @SerializedName("userName")
    val userName: String,

    @SerializedName("timestamp")
    val timestamp: Long = System.currentTimeMillis()
)

// Video Call Models
enum class CallState {
    @SerializedName("idle")
    IDLE,

    @SerializedName("outgoing")
    OUTGOING,

    @SerializedName("incoming")
    INCOMING,

    @SerializedName("connected")
    CONNECTED,

    @SerializedName("ended")
    ENDED
}

data class VideoCall(
    @SerializedName("id")
    val id: String,

    @SerializedName("callerId")
    val callerId: String,

    @SerializedName("callerName")
    val callerName: String,

    @SerializedName("callerAvatar")
    val callerAvatar: String?,

    @SerializedName("receiverId")
    val receiverId: String,

    @SerializedName("receiverName")
    val receiverName: String,

    @SerializedName("receiverAvatar")
    val receiverAvatar: String?,

    @SerializedName("state")
    val state: CallState = CallState.IDLE,

    @SerializedName("startTime")
    val startTime: Long? = null,

    @SerializedName("endTime")
    val endTime: Long? = null,

    @SerializedName("isVideoEnabled")
    val isVideoEnabled: Boolean = true,

    @SerializedName("isAudioEnabled")
    val isAudioEnabled: Boolean = true
)

data class CallSignal(
    @SerializedName("type")
    val type: String, // offer, answer, ice_candidate

    @SerializedName("callId")
    val callId: String,

    @SerializedName("fromUserId")
    val fromUserId: String,

    @SerializedName("toUserId")
    val toUserId: String,

    @SerializedName("sdp")
    val sdp: String? = null,

    @SerializedName("candidate")
    val candidate: String? = null
)

// Messaging Models
data class ChatMessage(
    @SerializedName("id")
    val id: String,

    @SerializedName("senderId")
    val senderId: String,

    @SerializedName("senderName")
    val senderName: String,

    @SerializedName("senderAvatar")
    val senderAvatar: String?,

    @SerializedName("receiverId")
    val receiverId: String,

    @SerializedName("message")
    val message: String,

    @SerializedName("timestamp")
    val timestamp: Long,

    @SerializedName("isRead")
    val isRead: Boolean = false,

    @SerializedName("isFromMe")
    val isFromMe: Boolean = false,

    @SerializedName("status")
    val status: MessageStatus = MessageStatus.SENT,

    @SerializedName("messageType")
    val messageType: MessageType = MessageType.TEXT,

    @SerializedName("imageUrl")
    val imageUrl: String? = null,

    @SerializedName("thumbnailUrl")
    val thumbnailUrl: String? = null,

    // Voice message fields
    @SerializedName("voiceUrl")
    val voiceUrl: String? = null,

    @SerializedName("voiceDuration")
    val voiceDuration: Int = 0, // Duration in seconds

    @SerializedName("waveform")
    val waveform: List<Float>? = null,

    // Reactions
    @SerializedName("reactions")
    val reactions: MutableList<MessageReaction> = mutableListOf()
)

// Typing Indicator
data class TypingIndicator(
    @SerializedName("type")
    val type: String = "typing",

    @SerializedName("userId")
    val userId: String,

    @SerializedName("userName")
    val userName: String,

    @SerializedName("conversationId")
    val conversationId: String,

    @SerializedName("isTyping")
    val isTyping: Boolean
)

// Read Receipt
data class ReadReceipt(
    @SerializedName("type")
    val type: String = "read_receipt",

    @SerializedName("messageId")
    val messageId: String,

    @SerializedName("conversationId")
    val conversationId: String,

    @SerializedName("readBy")
    val readBy: String,

    @SerializedName("readAt")
    val readAt: Long
)

data class Conversation(
    @SerializedName("id")
    val id: String,

    @SerializedName("participantId")
    val participantId: String,

    @SerializedName("participantName")
    val participantName: String,

    @SerializedName("participantAvatar")
    val participantAvatar: String?,

    @SerializedName("lastMessage")
    val lastMessage: String,

    @SerializedName("lastMessageTime")
    val lastMessageTime: Long,

    @SerializedName("unreadCount")
    val unreadCount: Int = 0,

    @SerializedName("isOnline")
    val isOnline: Boolean = false,

    @SerializedName("isTyping")
    val isTyping: Boolean = false
)

