package com.nourify.template.ui.screens.secondscreen

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import com.nourify.template.domain.usecases.SecondScreenUseCase
import org.koin.android.annotation.KoinViewModel

@KoinViewModel
class SecondScreenVM(
    private val useCase: SecondScreenUseCase,
) : ViewModel() {
    var uiState by mutableStateOf(SecondScreenUIState.toEmpty())
        private set

    init {
        /*useCase().apply {
            uiState =
                uiState.copy(
                    title = name,
                )
        }*/
    }
}
