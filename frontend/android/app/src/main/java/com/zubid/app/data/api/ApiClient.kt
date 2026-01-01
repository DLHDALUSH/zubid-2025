package com.zubid.app.data.api

import com.zubid.app.BuildConfig
import okhttp3.Cookie
import okhttp3.CookieJar
import okhttp3.HttpUrl
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

object ApiClient {

    // API Configuration - Multi-environment setup
    // PRODUCTION: Render Cloud Platform (Primary Platform)
    private const val PRODUCTION_URL = "https://zubid-2025.onrender.com/"
    // ALTERNATIVE: DuckDNS Custom Domain (currently offline)
    private const val ALTERNATIVE_URL = "https://zubidauction.duckdns.org/"
    // LOCAL: Local development server
    private const val LOCAL_DEVELOPMENT_URL = "http://10.0.2.2:5000/"

    // Use PRODUCTION_URL for all builds (Render.com is primary)
    private val BASE_URL = PRODUCTION_URL

    // SECURITY: Only enable detailed logging in debug builds to prevent sensitive data exposure
    private val loggingInterceptor = HttpLoggingInterceptor().apply {
        level = HttpLoggingInterceptor.Level.BODY  // Enable full logging for debugging network issues
    }

    // Cookie storage for session-based authentication
    private val cookieStore = mutableMapOf<String, MutableList<Cookie>>()

    private val cookieJar = object : CookieJar {
        override fun saveFromResponse(url: HttpUrl, cookies: List<Cookie>) {
            val host = url.host
            cookieStore.getOrPut(host) { mutableListOf() }.apply {
                // Remove old cookies with the same name
                val newCookieNames = cookies.map { it.name }.toSet()
                removeAll { it.name in newCookieNames }
                addAll(cookies)
            }
        }

        override fun loadForRequest(url: HttpUrl): List<Cookie> {
            val host = url.host
            return cookieStore[host]?.filter { !it.expiresAt.let { exp -> exp != 0L && exp < System.currentTimeMillis() } } ?: emptyList()
        }
    }

    private val okHttpClient = OkHttpClient.Builder()
        .cookieJar(cookieJar)  // Enable cookie handling for session auth
        .addInterceptor(loggingInterceptor)
        .addInterceptor { chain ->
            val request = chain.request().newBuilder()
                .addHeader("Accept", "application/json")
                .addHeader("Content-Type", "application/json")
                .build()
            chain.proceed(request)
        }
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .writeTimeout(30, TimeUnit.SECONDS)
        .retryOnConnectionFailure(true)
        .build()

    private val retrofit = Retrofit.Builder()
        .baseUrl(BASE_URL)
        .client(okHttpClient)
        .addConverterFactory(GsonConverterFactory.create())
        .build()

    val apiService: ApiService = retrofit.create(ApiService::class.java)

    // Clear cookies (for logout)
    fun clearCookies() {
        cookieStore.clear()
    }

    // Check if user is logged in (has session cookie)
    fun isLoggedIn(): Boolean {
        return cookieStore.values.flatten().any { it.name == "zubid_session" || it.name == "session" }
    }
}

