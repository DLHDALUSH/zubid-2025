package com.zubid.app

import android.app.Application
import androidx.appcompat.app.AppCompatDelegate
import com.zubid.app.data.local.SessionManager

class ZubidApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        
        // Initialize theme based on saved preference
        val sessionManager = SessionManager(this)
        applyTheme(sessionManager.getThemeMode())
    }

    private fun applyTheme(themeMode: Int) {
        when (themeMode) {
            0 -> AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)
            1 -> AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES)
            else -> AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM)
        }
    }
}

