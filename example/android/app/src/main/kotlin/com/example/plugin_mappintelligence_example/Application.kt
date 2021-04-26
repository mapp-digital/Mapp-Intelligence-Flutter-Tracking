package com.example.plugin_mappintelligence_example

import io.flutter.app.FlutterApplication
import webtrekk.android.sdk.Logger
import webtrekk.android.sdk.Webtrekk
import webtrekk.android.sdk.WebtrekkConfiguration

/**
 * Created by Aleksandar Marinkovic on 4/19/21.
 * Copyright (c) 2021 MAPP.
 */
class Application : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()

        var webtrekkConfigurations = WebtrekkConfiguration.Builder(
            listOf("794940687426749"),
            "http://tracker-int-01.webtrekk.net"
        ).logLevel(Logger.Level.BASIC)
            .setBatchSupport(true,150)


        Webtrekk.getInstance().init(this, webtrekkConfigurations.build())

    }
}