package com.zubid.app.ui.activity

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.app.AppCompatDelegate
import com.zubid.app.R
import com.zubid.app.data.local.SessionManager
import com.zubid.app.databinding.ActivitySettingsBinding
import com.zubid.app.util.BiometricHelper
import com.zubid.app.util.LocaleHelper

class SettingsActivity : AppCompatActivity() {

    private lateinit var binding: ActivitySettingsBinding
    private lateinit var sessionManager: SessionManager

    override fun attachBaseContext(newBase: android.content.Context) {
        super.attachBaseContext(LocaleHelper.onAttach(newBase))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySettingsBinding.inflate(layoutInflater)
        setContentView(binding.root)

        sessionManager = SessionManager(this)

        setupViews()
        loadSettings()
    }

    private fun setupViews() {
        binding.btnBack.setOnClickListener { finish() }

        binding.switchNotifications.setOnCheckedChangeListener { _, isChecked ->
            sessionManager.setPushNotifications(isChecked)
            val msg = if (isChecked) "Notifications enabled" else "Notifications disabled"
            Toast.makeText(this, msg, Toast.LENGTH_SHORT).show()
        }

        binding.switchBidAlerts.setOnCheckedChangeListener { _, isChecked ->
            sessionManager.setBidAlerts(isChecked)
        }

        binding.switchEmailUpdates.setOnCheckedChangeListener { _, isChecked ->
            sessionManager.setEmailUpdates(isChecked)
        }

        binding.switchDarkMode.setOnCheckedChangeListener { _, isChecked ->
            sessionManager.setDarkModeEnabled(isChecked)
            applyDarkMode(isChecked)
        }

        // Biometric toggle
        binding.switchBiometric?.let { switch ->
            if (BiometricHelper.isBiometricAvailable(this)) {
                switch.setOnCheckedChangeListener { _, isChecked ->
                    sessionManager.setBiometricEnabled(isChecked)
                    val msg = if (isChecked) getString(R.string.enable_biometric) + " enabled" else "Biometric disabled"
                    Toast.makeText(this, msg, Toast.LENGTH_SHORT).show()
                }
            } else {
                switch.isEnabled = false
                switch.isChecked = false
            }
        }

        // Language selection
        binding.btnLanguage?.setOnClickListener {
            showLanguageDialog()
        }

        // Theme selection
        binding.btnTheme?.setOnClickListener {
            showThemeDialog()
        }

        binding.btnClearCache.setOnClickListener {
            Toast.makeText(this, getString(R.string.cache_cleared), Toast.LENGTH_SHORT).show()
        }

        binding.btnPrivacyPolicy.setOnClickListener {
            Toast.makeText(this, getString(R.string.privacy_policy), Toast.LENGTH_SHORT).show()
        }

        binding.btnTerms.setOnClickListener {
            Toast.makeText(this, getString(R.string.terms), Toast.LENGTH_SHORT).show()
        }

        binding.btnAbout.setOnClickListener {
            Toast.makeText(this, "Zubid v1.0.0", Toast.LENGTH_SHORT).show()
        }
    }

    private fun showThemeDialog() {
        val themes = arrayOf(
            getString(R.string.light_mode),
            getString(R.string.dark_mode),
            getString(R.string.system_default)
        )
        val currentTheme = sessionManager.getThemeMode()

        AlertDialog.Builder(this, R.style.AlertDialogTheme)
            .setTitle(getString(R.string.theme))
            .setSingleChoiceItems(themes, currentTheme) { dialog, which ->
                sessionManager.setThemeMode(which)
                applyThemeMode(which)
                dialog.dismiss()
            }
            .setNegativeButton(getString(R.string.cancel), null)
            .show()
    }

    private fun applyThemeMode(mode: Int) {
        when (mode) {
            0 -> AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)
            1 -> AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES)
            2 -> AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM)
        }
    }

    private fun applyDarkMode(isDark: Boolean) {
        if (isDark) {
            AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES)
            sessionManager.setThemeMode(1)
        } else {
            AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)
            sessionManager.setThemeMode(0)
        }
    }

    private fun showLanguageDialog() {
        val languages = LocaleHelper.getAvailableLanguages()
        val languageNames = languages.map { it.second }.toTypedArray()
        val currentLanguage = LocaleHelper.getLanguage(this)
        val currentIndex = languages.indexOfFirst { it.first == currentLanguage }

        AlertDialog.Builder(this, R.style.AlertDialogTheme)
            .setTitle(getString(R.string.select_language))
            .setSingleChoiceItems(languageNames, currentIndex) { dialog, which ->
                val selectedLanguage = languages[which].first
                if (selectedLanguage != currentLanguage) {
                    LocaleHelper.setLocale(this, selectedLanguage)
                    // Restart app to apply language
                    val intent = packageManager.getLaunchIntentForPackage(packageName)
                    intent?.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    finishAffinity()
                }
                dialog.dismiss()
            }
            .setNegativeButton(getString(R.string.cancel), null)
            .show()
    }

    private fun loadSettings() {
        binding.switchNotifications.isChecked = sessionManager.isPushNotificationsEnabled()
        binding.switchBidAlerts.isChecked = sessionManager.isBidAlertsEnabled()
        binding.switchEmailUpdates.isChecked = sessionManager.isEmailUpdatesEnabled()
        binding.switchDarkMode.isChecked = sessionManager.isDarkModeEnabled()
        binding.switchBiometric?.isChecked = sessionManager.isBiometricEnabled()

        // Update language display
        val currentLanguage = LocaleHelper.getLanguage(this)
        binding.tvCurrentLanguage?.text = LocaleHelper.getLanguageDisplayName(currentLanguage)

        // Update theme display
        val themeMode = sessionManager.getThemeMode()
        binding.tvCurrentTheme?.text = when (themeMode) {
            0 -> getString(R.string.light_mode)
            1 -> getString(R.string.dark_mode)
            else -> getString(R.string.system_default)
        }
    }
}

