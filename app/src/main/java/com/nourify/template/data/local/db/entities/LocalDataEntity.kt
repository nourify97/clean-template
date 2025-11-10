package com.nourify.template.data.local.db.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "localData")
data class LocalDataEntity(
    @PrimaryKey val id: Int,
    val title: String,
    val completed: Boolean,
    val userId: Int,
)
