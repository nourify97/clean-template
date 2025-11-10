package com.nourify.template

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.navigation.compose.rememberNavController
import com.nourify.template.ui.navigation.FirstScreen
import com.nourify.template.ui.navigation.SetupNavGraph
import com.nourify.template.ui.theme.TemplateTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            TemplateTheme(dynamicColor = true) {
                val navController = rememberNavController()
                SetupNavGraph(
                    startDestination = FirstScreen,
                    navController = navController,
                )
            }
        }
    }
}
