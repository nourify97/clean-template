package com.nourify.template.ui.screens.firstscreen

import android.util.Log
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nourify.template.domain.models.Data
import com.nourify.template.domain.usecases.FirstScreenUseCase
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.koin.android.annotation.KoinViewModel

@KoinViewModel
class FirstScreenVM(
    private val useCase: FirstScreenUseCase,
) : ViewModel() {
    var uiState by mutableStateOf<FirstScreenUIState>(FirstScreenUIState.Loading)
        private set

    init {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val data = useCase()
                withContext(Dispatchers.Main) {
                    uiState = FirstScreenUIState.Success(data)
                }
                Log.d("FirstScreenVM", data.toString())
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    uiState = FirstScreenUIState.Error(e.localizedMessage ?: "Unknown error")
                }
            }
        }
    }

    fun onClick() {}
}
