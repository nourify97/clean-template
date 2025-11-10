package com.nourify.template.core.di

import android.content.Context
import androidx.room.Room
import com.nourify.template.data.local.db.AppDatabase
import com.nourify.template.data.local.db.dao.LocalDataDao
import org.koin.core.annotation.Module
import org.koin.core.annotation.Single

@Module
class DatabaseModule {
    @Single
    fun provideDatabase(context: Context): AppDatabase =
        Room
            .databaseBuilder(
                context,
                AppDatabase::class.java,
                "template.db",
            ).build()

    @Single
    fun provideTodoDao(db: AppDatabase): LocalDataDao = db.localDataDao()
}
