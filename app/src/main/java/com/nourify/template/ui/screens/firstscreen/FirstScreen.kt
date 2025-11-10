package com.nourify.template.ui.screens.firstscreen

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.text.TextAutoSize
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.CheckCircleOutline
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow.Companion.Ellipsis
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.nourify.template.domain.models.Data

@Composable
fun FirstScreen(
    modifier: Modifier = Modifier,
    uiState: FirstScreenUIState,
    onNavigateToSecondScreen: () -> Unit,
) {
    Column(
        modifier = modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        when (uiState) {
            FirstScreenUIState.Loading -> {
                CircularProgressIndicator()
            }
            is FirstScreenUIState.Error -> {
                Text(
                    text = uiState.errorMsg,
                    fontWeight = FontWeight.Bold,
                    color = Color.Red,
                )
            }
            is FirstScreenUIState.Success -> {
                LazyColumn(
                    modifier = modifier.padding(15.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    items(uiState.data) { todo ->
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(15.dp),
                        ) {
                            Text(text = todo.id.toString())
                            Text(
                                text = todo.title,
                                maxLines = 1,
                                overflow = Ellipsis,
                                modifier = Modifier.weight(1f),
                            )
                            Icon(
                                imageVector =
                                    if (todo.completed) {
                                        Icons.Default.CheckCircle
                                    } else {
                                        Icons.Default.CheckCircleOutline
                                    },
                                contentDescription = "",
                            )
                        }
                    }

                    item {
                        Button(
                            onNavigateToSecondScreen,
                        ) {
                            Text("second screen")
                        }
                    }
                }
            }
        }
    }
}

@Preview
@Composable
private fun FirstScreenPrev() {
    val fakeData =
        listOf(
            Data(id = 1, title = "Do groceries", completed = false),
            Data(id = 2, title = "Clean my car", completed = true),
            Data(id = 3, title = "Update the IT project", completed = false),
            Data(id = 4, title = "Drink more water", completed = true),
        )

    FirstScreen(
        uiState = FirstScreenUIState.Error("fake error"),
        onNavigateToSecondScreen = {},
    )
}
