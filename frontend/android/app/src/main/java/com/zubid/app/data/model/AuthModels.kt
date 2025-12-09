package com.zubid.app.data.model

import com.google.gson.annotations.SerializedName

data class LoginRequest(
    val email: String,
    val password: String
)

data class RegisterRequest(
    val name: String,
    val email: String,
    val password: String,
    @SerializedName("password_confirmation")
    val passwordConfirmation: String
)

data class AuthResponse(
    val success: Boolean,
    val message: String?,
    val token: String?,
    val user: User?
)

data class User(
    val id: String,
    val name: String,
    val email: String,
    @SerializedName("avatar_url")
    val avatarUrl: String?,
    @SerializedName("created_at")
    val createdAt: String?,
    val balance: Double = 0.0,
    @SerializedName("total_bids")
    val totalBids: Int = 0,
    @SerializedName("total_won")
    val totalWon: Int = 0
)

data class BidRequest(
    val amount: Double
)

data class BidResponse(
    val success: Boolean,
    val message: String?,
    @SerializedName("current_price")
    val currentPrice: Double?,
    @SerializedName("bid_count")
    val bidCount: Int?
)

