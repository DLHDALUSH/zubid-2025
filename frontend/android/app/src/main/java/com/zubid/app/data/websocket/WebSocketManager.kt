package com.zubid.app.data.websocket

import android.util.Log
import com.google.gson.Gson
import com.google.gson.JsonObject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.launch
import okhttp3.*
import java.util.concurrent.TimeUnit

class WebSocketManager private constructor() {

    companion object {
        private const val TAG = "WebSocketManager"
        private const val NORMAL_CLOSURE_STATUS = 1000
        private const val RECONNECT_DELAY_MS = 5000L
        private const val WS_URL = "wss://zubid-2025.onrender.com/ws"

        @Volatile
        private var instance: WebSocketManager? = null

        fun getInstance(): WebSocketManager {
            return instance ?: synchronized(this) {
                instance ?: WebSocketManager().also { instance = it }
            }
        }
    }

    private var webSocket: WebSocket? = null
    private var isConnected = false
    private var reconnectJob: Job? = null
    private val scope = CoroutineScope(Dispatchers.IO)
    private val gson = Gson()

    private val client = OkHttpClient.Builder()
        .readTimeout(30, TimeUnit.SECONDS)
        .writeTimeout(30, TimeUnit.SECONDS)
        .pingInterval(20, TimeUnit.SECONDS)
        .build()

    // Event flows
    private val _bidUpdates = MutableSharedFlow<BidUpdate>(replay = 1)
    val bidUpdates: SharedFlow<BidUpdate> = _bidUpdates.asSharedFlow()

    private val _auctionUpdates = MutableSharedFlow<AuctionUpdate>(replay = 1)
    val auctionUpdates: SharedFlow<AuctionUpdate> = _auctionUpdates.asSharedFlow()

    private val _connectionState = MutableSharedFlow<ConnectionState>(replay = 1)
    val connectionState: SharedFlow<ConnectionState> = _connectionState.asSharedFlow()

    fun connect(authToken: String? = null) {
        if (isConnected) return

        val requestBuilder = Request.Builder().url(WS_URL)
        authToken?.let { requestBuilder.addHeader("Authorization", "Bearer $it") }

        webSocket = client.newWebSocket(requestBuilder.build(), createWebSocketListener())
    }

    fun disconnect() {
        reconnectJob?.cancel()
        webSocket?.close(NORMAL_CLOSURE_STATUS, "User disconnected")
        webSocket = null
        isConnected = false
    }

    fun subscribeToAuction(auctionId: String) {
        val message = JsonObject().apply {
            addProperty("type", "subscribe")
            addProperty("channel", "auction")
            addProperty("auctionId", auctionId)
        }
        sendMessage(message.toString())
    }

    fun unsubscribeFromAuction(auctionId: String) {
        val message = JsonObject().apply {
            addProperty("type", "unsubscribe")
            addProperty("channel", "auction")
            addProperty("auctionId", auctionId)
        }
        sendMessage(message.toString())
    }

    fun placeBid(auctionId: String, amount: Double) {
        val message = JsonObject().apply {
            addProperty("type", "bid")
            addProperty("auctionId", auctionId)
            addProperty("amount", amount)
        }
        sendMessage(message.toString())
    }

    private fun sendMessage(message: String) {
        if (isConnected) {
            webSocket?.send(message)
            Log.d(TAG, "Sent: $message")
        } else {
            Log.w(TAG, "Cannot send message - not connected")
        }
    }

    private fun createWebSocketListener() = object : WebSocketListener() {
        override fun onOpen(webSocket: WebSocket, response: Response) {
            isConnected = true
            Log.d(TAG, "WebSocket connected")
            scope.launch { _connectionState.emit(ConnectionState.Connected) }
        }

        override fun onMessage(webSocket: WebSocket, text: String) {
            Log.d(TAG, "Received: $text")
            parseMessage(text)
        }

        override fun onClosing(webSocket: WebSocket, code: Int, reason: String) {
            Log.d(TAG, "WebSocket closing: $code - $reason")
        }

        override fun onClosed(webSocket: WebSocket, code: Int, reason: String) {
            isConnected = false
            Log.d(TAG, "WebSocket closed: $code - $reason")
            scope.launch { _connectionState.emit(ConnectionState.Disconnected) }
        }

        override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
            isConnected = false
            Log.e(TAG, "WebSocket error: ${t.message}")
            scope.launch { _connectionState.emit(ConnectionState.Error(t.message ?: "Unknown error")) }
            scheduleReconnect()
        }
    }

    private fun parseMessage(text: String) {
        try {
            val json = gson.fromJson(text, JsonObject::class.java)
            when (json.get("type")?.asString) {
                "bid_update" -> {
                    val update = gson.fromJson(json, BidUpdate::class.java)
                    scope.launch { _bidUpdates.emit(update) }
                }
                "auction_update" -> {
                    val update = gson.fromJson(json, AuctionUpdate::class.java)
                    scope.launch { _auctionUpdates.emit(update) }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing message: ${e.message}")
        }
    }

    private fun scheduleReconnect() {
        reconnectJob?.cancel()
        reconnectJob = scope.launch {
            delay(RECONNECT_DELAY_MS)
            Log.d(TAG, "Attempting to reconnect...")
            connect()
        }
    }
}

