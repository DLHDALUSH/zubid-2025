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
    val message: String?,
    val error: String?,
    @SerializedName("current_bid")
    val currentBid: Double?,
    @SerializedName("bid_id")
    val bidId: Int?,
    @SerializedName("time_extended")
    val timeExtended: Boolean?,
    @SerializedName("new_end_time")
    val newEndTime: String?,
    @SerializedName("time_left")
    val timeLeft: Int?
) {
    val success: Boolean
        get() = error == null && message != null
}

// Forgot Password - Request OTP
data class ForgotPasswordRequest(
    val email: String? = null,
    val phone: String? = null,
    val method: String = "email"  // "email" or "phone"
)

data class ForgotPasswordResponse(
    val message: String?,
    val error: String?,
    val method: String?,
    @SerializedName("expires_in")
    val expiresIn: Int?,
    @SerializedName("reset_code")
    val resetCode: String? = null  // Only in development mode
)

// Reset Password - Verify OTP and set new password
data class ResetPasswordRequest(
    val email: String? = null,
    val phone: String? = null,
    val token: String,
    @SerializedName("new_password")
    val newPassword: String
)

data class ResetPasswordResponse(
    val message: String?,
    val error: String?
)

data class BuyNowResponse(
    val message: String?,
    val error: String?,
    @SerializedName("auction_id")
    val auctionId: Int?,
    @SerializedName("purchase_price")
    val purchasePrice: Double?,
    @SerializedName("total_with_fees")
    val totalWithFees: Double?
) {
    val success: Boolean
        get() = error == null && message != null
}

