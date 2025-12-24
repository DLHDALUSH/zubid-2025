package com.zubid.app.util

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.zubid.app.R
import com.zubid.app.ui.activity.AuctionDetailActivity

object NotificationHelper {
    
    private const val CHANNEL_ID_BIDS = "zubid_bids"
    private const val CHANNEL_ID_MESSAGES = "zubid_messages"
    private const val CHANNEL_ID_GENERAL = "zubid_general"
    
    fun createNotificationChannels(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = context.getSystemService(NotificationManager::class.java)
            
            // Bids channel
            val bidsChannel = NotificationChannel(
                CHANNEL_ID_BIDS,
                context.getString(R.string.bid_notifications),
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for bids and auctions"
                enableVibration(true)
                enableLights(true)
            }
            
            // Messages channel
            val messagesChannel = NotificationChannel(
                CHANNEL_ID_MESSAGES,
                context.getString(R.string.message_notifications),
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Notifications for messages"
                enableVibration(true)
            }
            
            // General channel
            val generalChannel = NotificationChannel(
                CHANNEL_ID_GENERAL,
                context.getString(R.string.general_notifications),
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "General notifications"
            }
            
            notificationManager.createNotificationChannels(
                listOf(bidsChannel, messagesChannel, generalChannel)
            )
        }
    }
    
    fun showOutbidNotification(context: Context, auctionId: String, auctionTitle: String, newPrice: Double) {
        val intent = Intent(context, AuctionDetailActivity::class.java).apply {
            putExtra("auction_id", auctionId)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        
        val pendingIntent = PendingIntent.getActivity(
            context, auctionId.hashCode(), intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(context, CHANNEL_ID_BIDS)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(context.getString(R.string.outbid_title))
            .setContentText(context.getString(R.string.outbid_message, auctionTitle, formatPrice(newPrice)))
            .setStyle(NotificationCompat.BigTextStyle()
                .bigText(context.getString(R.string.outbid_message, auctionTitle, formatPrice(newPrice))))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setColor(context.getColor(R.color.coral))
            .addAction(R.drawable.ic_bid, context.getString(R.string.bid_now), pendingIntent)
            .build()
        
        val notificationManager = context.getSystemService(NotificationManager::class.java)
        notificationManager.notify(auctionId.hashCode(), notification)
    }
    
    fun showAuctionEndingSoonNotification(context: Context, auctionId: String, auctionTitle: String, minutesLeft: Int) {
        val intent = Intent(context, AuctionDetailActivity::class.java).apply {
            putExtra("auction_id", auctionId)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        
        val pendingIntent = PendingIntent.getActivity(
            context, auctionId.hashCode() + 1000, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(context, CHANNEL_ID_BIDS)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(context.getString(R.string.auction_ending_title))
            .setContentText(context.getString(R.string.auction_ending_message, auctionTitle, minutesLeft))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setColor(context.getColor(R.color.coral))
            .build()
        
        val notificationManager = context.getSystemService(NotificationManager::class.java)
        notificationManager.notify(auctionId.hashCode() + 1000, notification)
    }
    
    fun showWonAuctionNotification(context: Context, auctionId: String, auctionTitle: String, finalPrice: Double) {
        val intent = Intent(context, AuctionDetailActivity::class.java).apply {
            putExtra("auction_id", auctionId)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        
        val pendingIntent = PendingIntent.getActivity(
            context, auctionId.hashCode() + 2000, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(context, CHANNEL_ID_BIDS)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(context.getString(R.string.won_auction_title))
            .setContentText(context.getString(R.string.won_auction_message, auctionTitle, formatPrice(finalPrice)))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setColor(context.getColor(R.color.success))
            .build()
        
        val notificationManager = context.getSystemService(NotificationManager::class.java)
        notificationManager.notify(auctionId.hashCode() + 2000, notification)
    }
    
    fun showNewMessageNotification(context: Context, senderId: String, senderName: String, message: String) {
        val intent = Intent(context, Class.forName("com.zubid.app.ui.activity.ChatActivity")).apply {
            putExtra("user_id", senderId)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        
        val pendingIntent = PendingIntent.getActivity(
            context, senderId.hashCode(), intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(context, CHANNEL_ID_MESSAGES)
            .setSmallIcon(R.drawable.ic_message)
            .setContentTitle(senderName)
            .setContentText(message)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setColor(context.getColor(R.color.coral))
            .build()
        
        val notificationManager = context.getSystemService(NotificationManager::class.java)
        notificationManager.notify(senderId.hashCode(), notification)
    }
    
    private fun formatPrice(price: Double): String = String.format("$%.2f", price)
}

