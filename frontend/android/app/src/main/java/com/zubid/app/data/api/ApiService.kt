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

    // Authentication - matches backend /api/* routes
    @POST("api/login")
    suspend fun login(@Body request: LoginRequest): Response<AuthResponse>

    @POST("api/register")
    suspend fun register(@Body request: RegisterRequest): Response<AuthResponse>

    @GET("api/me")
    suspend fun getCurrentUser(@Header("Authorization") token: String): Response<User>

    @POST("api/logout")
    suspend fun logout(@Header("Authorization") token: String): Response<Unit>

    // Auctions
    @GET("api/auctions")
    suspend fun getAuctions(
        @Query("category") category: String? = null,
        @Query("search") search: String? = null,
        @Query("page") page: Int = 1,
        @Query("limit") limit: Int = 20
    ): Response<List<Auction>>

    @GET("api/auctions/{id}")
    suspend fun getAuction(@Path("id") id: String): Response<Auction>

    @GET("api/auctions")
    suspend fun getFeaturedAuctions(): Response<List<Auction>>

    // Bids
    @POST("api/auctions/{id}/bid")
    suspend fun placeBid(
        @Header("Authorization") token: String,
        @Path("id") auctionId: String,
        @Body request: BidRequest
    ): Response<BidResponse>

    @GET("api/my-bids")
    suspend fun getMyBids(@Header("Authorization") token: String): Response<List<Auction>>

    // Wishlist
    @GET("api/wishlist")
    suspend fun getWishlist(@Header("Authorization") token: String): Response<List<Auction>>

    @POST("api/wishlist/{auctionId}")
    suspend fun addToWishlist(
        @Header("Authorization") token: String,
        @Path("auctionId") auctionId: String
    ): Response<Unit>

    @DELETE("api/wishlist/{auctionId}")
    suspend fun removeFromWishlist(
        @Header("Authorization") token: String,
        @Path("auctionId") auctionId: String
    ): Response<Unit>

    // Won Auctions
    @GET("api/my-auctions")
    suspend fun getWonAuctions(@Header("Authorization") token: String): Response<List<Auction>>

    // Notifications
    @GET("api/notifications")
    suspend fun getNotifications(@Header("Authorization") token: String): Response<List<com.zubid.app.data.model.Notification>>

    @PUT("api/notifications/{id}/read")
    suspend fun markNotificationRead(
        @Header("Authorization") token: String,
        @Path("id") notificationId: String
    ): Response<Unit>
}

