package com.nourify.template.domain.repositories

import com.nourify.template.domain.models.Data

interface DataRepository {
    suspend fun getData(): List<Data>
}
