package com.nourify.template.data.local.db

import androidx.room.Database
import androidx.room.RoomDatabase
import com.nourify.template.data.local.db.dao.LocalDataDao
import com.nourify.template.data.local.db.entities.LocalDataEntity

@Database(
    entities = [LocalDataEntity::class],
    version = 1,
    exportSchema = false,
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun localDataDao(): LocalDataDao
}
