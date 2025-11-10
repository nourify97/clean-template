package com.nourify.template.ui.screens.firstscreen

import com.nourify.template.domain.models.Data

sealed class FirstScreenUIState {
    data object Loading : FirstScreenUIState()

    data class Success(
        val data: List<Data>,
    ) : FirstScreenUIState()

    data class Error(
        val errorMsg: String,
    ) : FirstScreenUIState()
}
