package com.zubid.app.data.api

import com.zubid.app.data.model.Auction
import com.zubid.app.data.model.AuctionsResponse
import com.zubid.app.data.model.AuthResponse
import com.zubid.app.data.model.BidRequest
import com.zubid.app.data.model.BidResponse
import com.zubid.app.data.model.BuyNowResponse
import com.zubid.app.data.model.ForgotPasswordRequest
import com.zubid.app.data.model.ForgotPasswordResponse
import com.zubid.app.data.model.LoginRequest
import com.zubid.app.data.model.RegisterRequest
import com.zubid.app.data.model.ResetPasswordRequest
import com.zubid.app.data.model.ResetPasswordResponse
import com.zubid.app.data.model.User
import retrofit2.Response
import retrofit2.http.*

interface ApiService {

    // Authentication - matches backend /api/* routes
    @POST("api/login")
    suspend fun login(@Body request: LoginRequest): Response<AuthResponse>

    @POST("api/register")
    suspend fun register(@Body request: RegisterRequest): Response<AuthResponse>

    @GET("api/me")
    suspend fun getCurrentUser(): Response<User>

    @POST("api/logout")
    suspend fun logout(): Response<Unit>

    // Forgot Password - Request OTP
    @POST("api/forgot-password")
    suspend fun forgotPassword(@Body request: ForgotPasswordRequest): Response<ForgotPasswordResponse>

    // Reset Password - Verify OTP and set new password
    @POST("api/reset-password")
    suspend fun resetPassword(@Body request: ResetPasswordRequest): Response<ResetPasswordResponse>

    // Auctions - returns paginated response with "auctions" array
    @GET("api/auctions")
    suspend fun getAuctions(
        @Query("category_id") categoryId: Int? = null,
        @Query("search") search: String? = null,
        @Query("page") page: Int = 1,
        @Query("per_page") perPage: Int = 20,
        @Query("status") status: String = "active"
    ): Response<AuctionsResponse>

    @GET("api/auctions/{id}")
    suspend fun getAuction(@Path("id") id: Int): Response<Auction>

    @GET("api/auctions")
    suspend fun getFeaturedAuctions(
        @Query("featured") featured: Boolean = true
    ): Response<AuctionsResponse>

    // Bids - backend expects /api/auctions/{id}/bids (plural)
    @POST("api/auctions/{id}/bids")
    suspend fun placeBid(
        @Path("id") auctionId: Int,
        @Body request: BidRequest
    ): Response<BidResponse>

    @GET("api/my-bids")
    suspend fun getMyBids(): Response<List<Auction>>

    // Wishlist
    @GET("api/wishlist")
    suspend fun getWishlist(): Response<List<Auction>>

    @POST("api/wishlist/{auctionId}")
    suspend fun addToWishlist(
        @Path("auctionId") auctionId: Int
    ): Response<Unit>

    @DELETE("api/wishlist/{auctionId}")
    suspend fun removeFromWishlist(
        @Path("auctionId") auctionId: Int
    ): Response<Unit>

    // Won Auctions
    @GET("api/my-auctions")
    suspend fun getWonAuctions(): Response<List<Auction>>

    // Notifications
    @GET("api/notifications")
    suspend fun getNotifications(): Response<List<com.zubid.app.data.model.Notification>>

    @PUT("api/notifications/{id}/read")
    suspend fun markNotificationRead(
        @Path("id") notificationId: Int
    ): Response<Unit>

    // Health check
    @GET("api/health")
    suspend fun healthCheck(): Response<Map<String, Any>>

    // Buy Now - backend expects /api/auctions/{id}/buy-now
    @POST("api/auctions/{id}/buy-now")
    suspend fun buyNow(
        @Path("id") auctionId: Int
    ): Response<BuyNowResponse>

    // CSRF token
    @GET("api/csrf-token")
    suspend fun getCsrfToken(): Response<Map<String, String>>
}

