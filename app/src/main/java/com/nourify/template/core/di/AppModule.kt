package com.nourify.template.core.di

import org.koin.core.annotation.ComponentScan
import org.koin.core.annotation.Module

@Module(includes = [DatabaseModule::class, NetworkModule::class])
@ComponentScan("com.nourify.template")
class AppModule
