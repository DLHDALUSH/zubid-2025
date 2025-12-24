package com.zubid.app.data.model

data class Category(
    val id: String,
    val name: String,
    val icon: String? = null,
    val itemCount: Int = 0,
    var isSelected: Boolean = false
)

