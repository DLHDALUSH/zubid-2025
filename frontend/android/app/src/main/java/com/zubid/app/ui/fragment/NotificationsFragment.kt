package com.zubid.app.ui.fragment

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import com.zubid.app.R
import com.zubid.app.data.model.Notification
import com.zubid.app.databinding.FragmentNotificationsBinding
import com.zubid.app.ui.adapter.NotificationAdapter

class NotificationsFragment : Fragment() {

    private var _binding: FragmentNotificationsBinding? = null
    private val binding get() = _binding!!
    private lateinit var notificationAdapter: NotificationAdapter

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentNotificationsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupRecyclerView()
        setupSwipeRefresh()
        loadNotifications()
    }

    private fun setupRecyclerView() {
        notificationAdapter = NotificationAdapter { notification ->
            // Handle notification click
        }

        binding.notificationsRecyclerView.apply {
            layoutManager = LinearLayoutManager(context)
            adapter = notificationAdapter
        }
    }

    private fun setupSwipeRefresh() {
        binding.swipeRefresh.setColorSchemeResources(R.color.coral)
        binding.swipeRefresh.setProgressBackgroundColorSchemeResource(R.color.bg_secondary)
        binding.swipeRefresh.setOnRefreshListener {
            loadNotifications()
        }
    }

    private fun loadNotifications() {
        // Sample data - replace with API call
        val notifications = listOf(
            Notification("1", "You've been outbid!", "Someone placed a higher bid on iPhone 15 Pro Max", 
                System.currentTimeMillis() - 300000, "outbid", false),
            Notification("2", "Auction ending soon", "iPhone 15 Pro Max ends in 30 minutes", 
                System.currentTimeMillis() - 1800000, "ending", false),
            Notification("3", "Congratulations!", "You won the Apple AirPods Pro auction!", 
                System.currentTimeMillis() - 86400000, "won", true),
            Notification("4", "New auction", "A new Rolex watch has been listed", 
                System.currentTimeMillis() - 172800000, "new", true)
        )

        notificationAdapter.submitList(notifications)
        binding.swipeRefresh.isRefreshing = false

        // Show/hide empty state
        if (notifications.isEmpty()) {
            binding.emptyState.visibility = View.VISIBLE
            binding.notificationsRecyclerView.visibility = View.GONE
        } else {
            binding.emptyState.visibility = View.GONE
            binding.notificationsRecyclerView.visibility = View.VISIBLE
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}

