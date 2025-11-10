package com.nourify.template.ui.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavGraphBuilder
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import com.nourify.template.ui.screens.firstscreen.FirstScreen
import com.nourify.template.ui.screens.firstscreen.FirstScreenVM
import com.nourify.template.ui.screens.secondscreen.SecondScreen
import com.nourify.template.ui.screens.secondscreen.SecondScreenVM
import org.koin.compose.viewmodel.koinViewModel

@Composable
fun SetupNavGraph(
    startDestination: Any,
    navController: NavHostController,
) {
    NavHost(
        startDestination = startDestination,
        navController = navController,
    ) {
        firstScreenRoute { navController.navigate(route = SecondScreen) }
        secondScreenRoute { navController.popBackStack() }
    }
}

private fun NavGraphBuilder.firstScreenRoute(onNavigateToSecondScreen: () -> Unit) {
    composable<FirstScreen> {
        val vm: FirstScreenVM = koinViewModel()
        val screenState = vm.uiState

        FirstScreen(
            uiState = screenState,
        ) {
            onNavigateToSecondScreen()
        }
    }
}

private fun NavGraphBuilder.secondScreenRoute(onNavigateBack: () -> Unit) {
    composable<SecondScreen> {
        val vm: SecondScreenVM = koinViewModel()

        SecondScreen(
            title = "",
            btnOnclick = onNavigateBack,
        )
    }
}
