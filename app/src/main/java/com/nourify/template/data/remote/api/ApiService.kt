package com.nourify.template.data.remote.api

import com.nourify.template.data.dto.DataDto
import retrofit2.Response
import retrofit2.http.GET

interface ApiService {
    @GET("todos")
    suspend fun getRemoteData(): Response<List<DataDto>>
}
