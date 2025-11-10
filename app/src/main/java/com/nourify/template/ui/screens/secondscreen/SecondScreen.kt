package com.nourify.template.ui.screens.secondscreen

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp

@Composable
fun SecondScreen(
    modifier: Modifier = Modifier,
    title: String,
    btnOnclick: () -> Unit,
) {
    Column(
        modifier = modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text(title)
        Spacer(modifier = Modifier.height(10.dp))
        Button(onClick = btnOnclick) {
            Text("Back")
        }
    }
}

@Preview
@Composable
private fun SecondScreenPrev() {
    SecondScreen(
        title = "Second Screen",
        btnOnclick = {},
    )
}
