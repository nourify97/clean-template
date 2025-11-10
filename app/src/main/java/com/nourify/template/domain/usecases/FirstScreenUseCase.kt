package com.nourify.template.domain.usecases

import com.nourify.template.domain.repositories.DataRepository
import org.koin.core.annotation.Single

@Single
class FirstScreenUseCase(
    private val repository: DataRepository,
) {
    suspend operator fun invoke() = repository.getData()
}
