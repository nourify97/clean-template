package com.nourify.template.data.local.db.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.nourify.template.data.local.db.entities.LocalDataEntity

@Dao
interface LocalDataDao {
    @Query("SELECT * FROM localData")
    suspend fun getAll(): List<LocalDataEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(items: List<LocalDataEntity>)

    @Query("DELETE FROM localData")
    suspend fun clear()
}
