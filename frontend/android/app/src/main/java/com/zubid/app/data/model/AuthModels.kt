package com.zubid.app.data.model

import com.google.gson.annotations.SerializedName

// Login with username (backend expects username, not email)
data class LoginRequest(
    val username: String,
    val password: String
)

// Registration - matches backend required fields
data class RegisterRequest(
    val username: String,
    val email: String,
    val password: String,
    @SerializedName("id_number")
    val idNumber: String,
    @SerializedName("birth_date")
    val birthDate: String,  // Format: YYYY-MM-DD
    val phone: String,
    val address: String,
    @SerializedName("first_name")
    val firstName: String? = null,
    @SerializedName("last_name")
    val lastName: String? = null
)

// Response from login/register
data class AuthResponse(
    val message: String?,
    val error: String?,
    val user: User?
)

data class User(
    val id: String,
    val username: String,
    val email: String,
    val role: String? = null,
    @SerializedName("profile_photo")
    val profilePhoto: String? = null,
    @SerializedName("first_name")
    val firstName: String? = null,
    @SerializedName("last_name")
    val lastName: String? = null,
    val balance: Double = 0.0
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

