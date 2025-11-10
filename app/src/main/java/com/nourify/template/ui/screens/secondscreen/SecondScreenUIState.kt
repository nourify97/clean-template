package com.nourify.template.ui.screens.secondscreen

data class SecondScreenUIState(
    val title: String,
) {
    companion object {
        fun toEmpty() =
            SecondScreenUIState(
                title = "",
            )
    }
}
