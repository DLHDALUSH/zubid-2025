package com.zubid.app.util

import android.content.Context
import android.content.res.Configuration
import android.os.Build
import java.util.Locale

object LocaleHelper {

    private const val PREF_NAME = "zubid_locale"
    private const val KEY_LANGUAGE = "language"

    const val ENGLISH = "en"
    const val ARABIC = "ar"
    const val KURDISH = "ku"

    fun setLocale(context: Context, language: String): Context {
        saveLanguage(context, language)
        return updateResources(context, language)
    }

    fun getLanguage(context: Context): String {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        return prefs.getString(KEY_LANGUAGE, ENGLISH) ?: ENGLISH
    }

    private fun saveLanguage(context: Context, language: String) {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString(KEY_LANGUAGE, language).apply()
    }

    fun onAttach(context: Context): Context {
        val language = getLanguage(context)
        return setLocale(context, language)
    }

    private fun updateResources(context: Context, language: String): Context {
        val locale = Locale(language)
        Locale.setDefault(locale)

        val config = Configuration(context.resources.configuration)
        config.setLocale(locale)
        config.setLayoutDirection(locale)

        return context.createConfigurationContext(config)
    }

    fun isRtl(language: String): Boolean {
        return language == ARABIC || language == KURDISH
    }

    fun getLanguageDisplayName(language: String): String {
        return when (language) {
            ENGLISH -> "English"
            ARABIC -> "العربية"
            KURDISH -> "کوردی"
            else -> "English"
        }
    }

    fun getAvailableLanguages(): List<Pair<String, String>> {
        return listOf(
            ENGLISH to "English",
            ARABIC to "العربية",
            KURDISH to "کوردی"
        )
    }
}

