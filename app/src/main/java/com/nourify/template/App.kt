package com.nourify.template

import android.app.Application
import com.nourify.template.core.di.AppModule
import com.nourify.template.core.di.DatabaseModule
import com.nourify.template.core.di.NetworkModule
import org.koin.android.ext.koin.androidContext
import org.koin.android.ext.koin.androidLogger
import org.koin.core.context.startKoin
import org.koin.ksp.generated.module

class App : Application() {
    override fun onCreate() {
        super.onCreate()
        startKoin {
            androidLogger()
            androidContext(this@App)
            modules(
                listOf(
                    AppModule().module,
                    NetworkModule().module,
                    DatabaseModule().module,
                ),
            )
        }
    }
}
