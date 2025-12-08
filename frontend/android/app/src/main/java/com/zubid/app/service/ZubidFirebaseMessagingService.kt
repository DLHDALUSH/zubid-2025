package com.zubid.app.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.zubid.app.MainActivity
import com.zubid.app.R

class ZubidFirebaseMessagingService : FirebaseMessagingService() {

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        // Send token to your backend server
        sendTokenToServer(token)
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        // Check if message contains a notification payload
        remoteMessage.notification?.let { notification ->
            showNotification(
                notification.title ?: "Zubid",
                notification.body ?: ""
            )
        }

        // Check if message contains data payload
        if (remoteMessage.data.isNotEmpty()) {
            handleDataMessage(remoteMessage.data)
        }
    }

    private fun showNotification(title: String, message: String) {
        val channelId = "zubid_notifications"
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Create notification channel for Android O+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Zubid Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Auction and bid notifications"
                enableLights(true)
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(channel)
        }

        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }

        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(title)
            .setContentText(message)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setColor(getColor(R.color.coral))
            .build()

        notificationManager.notify(System.currentTimeMillis().toInt(), notification)
    }

    private fun handleDataMessage(data: Map<String, String>) {
        val type = data["type"]
        when (type) {
            "outbid" -> {
                showNotification(
                    "You've been outbid!",
                    data["message"] ?: "Someone placed a higher bid"
                )
            }
            "auction_ending" -> {
                showNotification(
                    "Auction ending soon!",
                    data["message"] ?: "Don't miss out"
                )
            }
            "won" -> {
                showNotification(
                    "Congratulations! 🎉",
                    data["message"] ?: "You won an auction"
                )
            }
            "bid_placed" -> {
                showNotification(
                    "Bid confirmed",
                    data["message"] ?: "Your bid has been placed"
                )
            }
        }
    }

    private fun sendTokenToServer(token: String) {
        // TODO: Send FCM token to your backend
        // Use ApiClient.apiService.updateFcmToken(token)
    }
}

