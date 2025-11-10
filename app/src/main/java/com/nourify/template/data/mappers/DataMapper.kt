package com.nourify.template.data.mappers

import com.nourify.template.data.dto.DataDto
import com.nourify.template.data.local.db.entities.LocalDataEntity
import com.nourify.template.domain.models.Data
import org.koin.core.annotation.Single

@Single
class DataMapper {
    fun fromDataDtoToData(dataDto: DataDto) =
        Data(
            id = dataDto.id,
            title = dataDto.title,
            completed = dataDto.completed,
        )

    fun fromDataEntityToData(dataEntity: LocalDataEntity) =
        Data(
            id = dataEntity.id,
            title = dataEntity.title,
            completed = dataEntity.completed,
        )

    fun fromDataDtoToDataEntity(dataDto: DataDto) =
        LocalDataEntity(
            id = dataDto.id,
            title = dataDto.title,
            completed = dataDto.completed,
            userId = dataDto.userId,
        )
}
