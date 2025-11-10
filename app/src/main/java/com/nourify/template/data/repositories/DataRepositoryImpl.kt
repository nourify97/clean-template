package com.nourify.template.data.repositories

import com.nourify.template.data.local.db.dao.LocalDataDao
import com.nourify.template.data.mappers.DataMapper
import com.nourify.template.data.remote.api.ApiService
import com.nourify.template.domain.models.Data
import com.nourify.template.domain.repositories.DataRepository
import org.koin.core.annotation.Single

@Single
class DataRepositoryImpl(
    private val dataDao: LocalDataDao,
    private val apiService: ApiService,
    private val dataMapper: DataMapper,
) : DataRepository {
    override suspend fun getData(): List<Data> {
        val local = dataDao.getAll()

        if (local.isNotEmpty()) {
            return local.map(dataMapper::fromDataEntityToData)
        }

        val response = apiService.getRemoteData()
        if (!response.isSuccessful) {
            return emptyList()
        }

        val remoteData = response.body().orEmpty()
        dataDao.clear()
        dataDao.insertAll(remoteData.map(dataMapper::fromDataDtoToDataEntity))
        return remoteData.map(dataMapper::fromDataDtoToData)
    }
}
