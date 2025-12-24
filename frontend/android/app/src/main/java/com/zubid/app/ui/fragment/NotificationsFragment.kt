package com.zubid.app.ui.fragment

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import com.zubid.app.R
import com.zubid.app.data.api.ApiClient
import com.zubid.app.data.local.SessionManager
import com.zubid.app.data.model.Notification
import com.zubid.app.databinding.FragmentNotificationsBinding
import com.zubid.app.ui.adapter.NotificationAdapter
import kotlinx.coroutines.launch

class NotificationsFragment : Fragment() {

    private var _binding: FragmentNotificationsBinding? = null
    private val binding get() = _binding!!
    private lateinit var notificationAdapter: NotificationAdapter
    private lateinit var sessionManager: SessionManager

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
        sessionManager = SessionManager(requireContext())
        setupRecyclerView()
        setupSwipeRefresh()
        loadNotifications()
    }

    private fun setupRecyclerView() {
        notificationAdapter = NotificationAdapter { notification ->
            markAsRead(notification)
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
        binding.swipeRefresh.isRefreshing = true

        if (!sessionManager.isLoggedIn()) {
            showEmptyState(emptyList())
            binding.swipeRefresh.isRefreshing = false
            return
        }

        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val response = ApiClient.apiService.getNotifications()
                if (response.isSuccessful && response.body() != null) {
                    showEmptyState(response.body()!!)
                } else {
                    showEmptyState(emptyList())
                }
            } catch (e: Exception) {
                e.printStackTrace()
                showEmptyState(emptyList())
            } finally {
                binding.swipeRefresh.isRefreshing = false
            }
        }
    }

    private fun markAsRead(notification: Notification) {
        if (notification.isRead) return

        viewLifecycleOwner.lifecycleScope.launch {
            try {
                ApiClient.apiService.markNotificationRead(notification.id.toInt())
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun showEmptyState(notifications: List<Notification>) {
        notificationAdapter.submitList(notifications)
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

