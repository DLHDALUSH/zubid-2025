package com.zubid.app.data.api

import com.zubid.app.data.model.Auction
import com.zubid.app.data.model.AuthResponse
import com.zubid.app.data.model.BidRequest
import com.zubid.app.data.model.BidResponse
import com.zubid.app.data.model.LoginRequest
import com.zubid.app.data.model.RegisterRequest
import com.zubid.app.data.model.User
import retrofit2.Response
import retrofit2.http.*

interface ApiService {

    // Authentication
    @POST("auth/login")
    suspend fun login(@Body request: LoginRequest): Response<AuthResponse>

    @POST("auth/register")
    suspend fun register(@Body request: RegisterRequest): Response<AuthResponse>

    @GET("auth/me")
    suspend fun getCurrentUser(@Header("Authorization") token: String): Response<User>

    @POST("auth/logout")
    suspend fun logout(@Header("Authorization") token: String): Response<Unit>

    // Auctions
    @GET("auctions")
    suspend fun getAuctions(
        @Query("category") category: String? = null,
        @Query("search") search: String? = null,
        @Query("page") page: Int = 1,
        @Query("limit") limit: Int = 20
    ): Response<List<Auction>>

    @GET("auctions/{id}")
    suspend fun getAuction(@Path("id") id: String): Response<Auction>

    @GET("auctions/featured")
    suspend fun getFeaturedAuctions(): Response<List<Auction>>

    // Bids
    @POST("auctions/{id}/bid")
    suspend fun placeBid(
        @Header("Authorization") token: String,
        @Path("id") auctionId: String,
        @Body request: BidRequest
    ): Response<BidResponse>

    @GET("users/me/bids")
    suspend fun getMyBids(@Header("Authorization") token: String): Response<List<Auction>>

    // Wishlist
    @GET("users/me/wishlist")
    suspend fun getWishlist(@Header("Authorization") token: String): Response<List<Auction>>

    @POST("users/me/wishlist/{auctionId}")
    suspend fun addToWishlist(
        @Header("Authorization") token: String,
        @Path("auctionId") auctionId: String
    ): Response<Unit>

    @DELETE("users/me/wishlist/{auctionId}")
    suspend fun removeFromWishlist(
        @Header("Authorization") token: String,
        @Path("auctionId") auctionId: String
    ): Response<Unit>

    // Won Auctions
    @GET("users/me/won")
    suspend fun getWonAuctions(@Header("Authorization") token: String): Response<List<Auction>>

    // Notifications
    @GET("users/me/notifications")
    suspend fun getNotifications(@Header("Authorization") token: String): Response<List<com.zubid.app.data.model.Notification>>

    @PUT("users/me/notifications/{id}/read")
    suspend fun markNotificationRead(
        @Header("Authorization") token: String,
        @Path("id") notificationId: String
    ): Response<Unit>
}

