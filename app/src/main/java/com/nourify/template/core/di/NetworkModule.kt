package com.nourify.template.core.di

import android.util.Log
import com.jakewharton.retrofit2.converter.kotlinx.serialization.asConverterFactory
import com.nourify.template.BuildConfig
import com.nourify.template.data.remote.api.ApiService
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import org.koin.core.annotation.Module
import org.koin.core.annotation.Named
import org.koin.core.annotation.Single
import retrofit2.Retrofit

@Module
class NetworkModule {
    private val networkJson = Json { ignoreUnknownKeys = true }

    @Single
    @Named("BaseUrl")
    fun provideBaseUrl(): String {
        val url = BuildConfig.BASE_URL
        Log.d("NetworkModule", url)
        return url
    }

    @Single
    fun provideOkHttpClient(): OkHttpClient {
        val builder = OkHttpClient.Builder()

        if (BuildConfig.DEBUG) {
            HttpLoggingInterceptor()
                .apply {
                    level = HttpLoggingInterceptor.Level.BODY
                }.let {
                    builder.addInterceptor(it)
                }
        }

        return builder.build()
    }

    @Single
    fun provideRetrofit(
        @Named("BaseUrl") baseUrl: String,
        client: OkHttpClient,
    ): Retrofit =
        Retrofit
            .Builder()
            .baseUrl(baseUrl)
            .addConverterFactory(
                networkJson.asConverterFactory(
                    "application/json".toMediaType(),
                ),
            ).client(client)
            .build()

    @Single
    fun provideApiService(retrofit: Retrofit): ApiService = retrofit.create(ApiService::class.java)
}
