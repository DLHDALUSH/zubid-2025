package com.zubid.app.data.local

import android.content.Context
import android.content.SharedPreferences
import com.google.gson.Gson
import com.zubid.app.data.model.User

class SessionManager(context: Context) {
    
    private val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    private val gson = Gson()
    
    companion object {
        private const val PREFS_NAME = "zubid_session"
        private const val KEY_TOKEN = "auth_token"
        private const val KEY_USER = "user_data"
        private const val KEY_IS_LOGGED_IN = "is_logged_in"
        private const val KEY_BIOMETRIC_ENABLED = "biometric_enabled"
        private const val KEY_PUSH_NOTIFICATIONS = "push_notifications"
        private const val KEY_BID_ALERTS = "bid_alerts"
        private const val KEY_EMAIL_UPDATES = "email_updates"
        private const val KEY_PROFILE_IMAGE = "profile_image_path"
        private const val KEY_DARK_MODE = "dark_mode"
        private const val KEY_THEME_MODE = "theme_mode"
    }
    
    fun saveAuthToken(token: String) {
        prefs.edit().putString(KEY_TOKEN, token).apply()
    }
    
    fun getAuthToken(): String? {
        return prefs.getString(KEY_TOKEN, null)
    }
    
    fun saveUser(user: User) {
        val userJson = gson.toJson(user)
        prefs.edit().putString(KEY_USER, userJson).apply()
        prefs.edit().putBoolean(KEY_IS_LOGGED_IN, true).apply()
    }
    
    fun getUser(): User? {
        val userJson = prefs.getString(KEY_USER, null) ?: return null
        return try {
            gson.fromJson(userJson, User::class.java)
        } catch (e: Exception) {
            null
        }
    }
    
    fun isLoggedIn(): Boolean {
        return prefs.getBoolean(KEY_IS_LOGGED_IN, false) && getAuthToken() != null
    }
    
    fun logout() {
        prefs.edit().clear().apply()
    }
    
    fun getBearerToken(): String {
        return "Bearer ${getAuthToken()}"
    }

    // Biometric settings
    fun setBiometricEnabled(enabled: Boolean) {
        prefs.edit().putBoolean(KEY_BIOMETRIC_ENABLED, enabled).apply()
    }

    fun isBiometricEnabled(): Boolean {
        return prefs.getBoolean(KEY_BIOMETRIC_ENABLED, false)
    }

    // Notification settings
    fun setPushNotifications(enabled: Boolean) {
        prefs.edit().putBoolean(KEY_PUSH_NOTIFICATIONS, enabled).apply()
    }

    fun isPushNotificationsEnabled(): Boolean {
        return prefs.getBoolean(KEY_PUSH_NOTIFICATIONS, true)
    }

    fun setBidAlerts(enabled: Boolean) {
        prefs.edit().putBoolean(KEY_BID_ALERTS, enabled).apply()
    }

    fun isBidAlertsEnabled(): Boolean {
        return prefs.getBoolean(KEY_BID_ALERTS, true)
    }

    fun setEmailUpdates(enabled: Boolean) {
        prefs.edit().putBoolean(KEY_EMAIL_UPDATES, enabled).apply()
    }

    fun isEmailUpdatesEnabled(): Boolean {
        return prefs.getBoolean(KEY_EMAIL_UPDATES, true)
    }

    // Profile image
    fun saveProfileImagePath(path: String) {
        prefs.edit().putString(KEY_PROFILE_IMAGE, path).apply()
    }

    fun getProfileImagePath(): String? {
        return prefs.getString(KEY_PROFILE_IMAGE, null)
    }

    // Get user ID
    fun getUserId(): String? {
        return getUser()?.id
    }

    // Dark mode settings
    fun setDarkModeEnabled(enabled: Boolean) {
        prefs.edit().putBoolean(KEY_DARK_MODE, enabled).apply()
    }

    fun isDarkModeEnabled(): Boolean {
        return prefs.getBoolean(KEY_DARK_MODE, false) // Default to light mode
    }

    // Theme mode: 0 = Light, 1 = Dark, 2 = System
    fun setThemeMode(mode: Int) {
        prefs.edit().putInt(KEY_THEME_MODE, mode).apply()
        setDarkModeEnabled(mode == 1)
    }

    fun getThemeMode(): Int {
        return prefs.getInt(KEY_THEME_MODE, 2) // Default to system
    }
}

