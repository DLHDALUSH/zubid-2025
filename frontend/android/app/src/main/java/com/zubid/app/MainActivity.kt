package com.zubid.app

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.EditText
import android.widget.ImageButton
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.GravityCompat
import androidx.drawerlayout.widget.DrawerLayout
import androidx.fragment.app.Fragment
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.google.android.material.navigation.NavigationView
import com.zubid.app.data.api.ApiClient
import com.zubid.app.data.local.SessionManager
import com.zubid.app.ui.activity.LoginActivity
import com.zubid.app.ui.fragment.BidsFragment
import com.zubid.app.ui.fragment.HomeFragment
import com.zubid.app.ui.fragment.NotificationsFragment
import com.zubid.app.ui.fragment.WishlistFragment
import com.zubid.app.ui.fragment.WonsFragment
import com.zubid.app.util.LocaleHelper

class MainActivity : AppCompatActivity() {

    private lateinit var drawerLayout: DrawerLayout
    private lateinit var navView: NavigationView
    private lateinit var bottomNav: BottomNavigationView
    private lateinit var searchInput: EditText
    private lateinit var menuBtn: ImageButton
    private lateinit var sessionManager: SessionManager

    override fun attachBaseContext(newBase: Context) {
        super.attachBaseContext(LocaleHelper.onAttach(newBase))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        sessionManager = SessionManager(this)

        setupViews()
        setupBottomNavigation()
        setupDrawer()
        updateDrawerHeader()

        // Load home fragment by default
        if (savedInstanceState == null) {
            loadFragment(HomeFragment())
        }
    }

    private fun setupViews() {
        drawerLayout = findViewById(R.id.drawerLayout)
        navView = findViewById(R.id.navView)
        bottomNav = findViewById(R.id.bottomNav)
        searchInput = findViewById(R.id.searchInput)
        menuBtn = findViewById(R.id.btnMenu)

        menuBtn.setOnClickListener {
            drawerLayout.openDrawer(GravityCompat.START)
        }

        searchInput.setOnEditorActionListener { _, _, _ ->
            val query = searchInput.text.toString()
            if (query.isNotEmpty()) {
                Toast.makeText(this, "Search: $query", Toast.LENGTH_SHORT).show()
            }
            true
        }
    }

    private fun setupDrawer() {
        navView.setNavigationItemSelectedListener { menuItem ->
            when (menuItem.itemId) {
                R.id.nav_home -> {
                    loadFragment(HomeFragment())
                    bottomNav.selectedItemId = R.id.nav_home
                }
                R.id.nav_my_bids -> {
                    loadFragment(BidsFragment())
                    bottomNav.selectedItemId = R.id.nav_bids
                }
                R.id.nav_wishlist -> {
                    loadFragment(WishlistFragment())
                    bottomNav.selectedItemId = R.id.nav_wishlist
                }
                R.id.nav_won_auctions -> {
                    loadFragment(WonsFragment())
                    bottomNav.selectedItemId = R.id.nav_wons
                }
                R.id.nav_messages -> {
                    startActivity(Intent(this, com.zubid.app.ui.activity.MessagesActivity::class.java))
                }
                R.id.nav_profile -> {
                    startActivity(Intent(this, com.zubid.app.ui.activity.ProfileActivity::class.java))
                }
                R.id.nav_settings -> {
                    startActivity(Intent(this, com.zubid.app.ui.activity.SettingsActivity::class.java))
                }
                R.id.nav_help -> {
                    Toast.makeText(this, "Help & Support", Toast.LENGTH_SHORT).show()
                }
                R.id.nav_logout -> {
                    logout()
                }
            }
            drawerLayout.closeDrawer(GravityCompat.START)
            true
        }
    }

    private fun updateDrawerHeader() {
        val headerView = navView.getHeaderView(0)
        val userName = headerView.findViewById<TextView>(R.id.userName)
        val userEmail = headerView.findViewById<TextView>(R.id.userEmail)

        if (sessionManager.isLoggedIn()) {
            val user = sessionManager.getUser()
            // Use firstName + lastName if available, otherwise username
            val displayName = if (!user?.firstName.isNullOrEmpty() && !user?.lastName.isNullOrEmpty()) {
                "${user?.firstName} ${user?.lastName}"
            } else {
                user?.username ?: "User"
            }
            userName.text = displayName
            userEmail.text = user?.email ?: ""
        } else {
            userName.text = "Guest User"
            userEmail.text = "Tap to login"
            headerView.setOnClickListener {
                startActivity(Intent(this, LoginActivity::class.java))
                drawerLayout.closeDrawer(GravityCompat.START)
            }
        }
    }

    private fun logout() {
        sessionManager.logout()
        ApiClient.clearCookies()  // Clear session cookies
        Toast.makeText(this, "Logged out", Toast.LENGTH_SHORT).show()
        startActivity(Intent(this, LoginActivity::class.java))
        finish()
    }

    private fun setupBottomNavigation() {
        bottomNav.setOnItemSelectedListener { item ->
            when (item.itemId) {
                R.id.nav_home -> { loadFragment(HomeFragment()); true }
                R.id.nav_bids -> { loadFragment(BidsFragment()); true }
                R.id.nav_wishlist -> { loadFragment(WishlistFragment()); true }
                R.id.nav_wons -> { loadFragment(WonsFragment()); true }
                R.id.nav_notifications -> { loadFragment(NotificationsFragment()); true }
                else -> false
            }
        }
    }

    private fun loadFragment(fragment: Fragment) {
        supportFragmentManager.beginTransaction()
            .replace(R.id.fragmentContainer, fragment)
            .commit()
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        if (drawerLayout.isDrawerOpen(GravityCompat.START)) {
            drawerLayout.closeDrawer(GravityCompat.START)
        } else {
            @Suppress("DEPRECATION")
            super.onBackPressed()
        }
    }
}

