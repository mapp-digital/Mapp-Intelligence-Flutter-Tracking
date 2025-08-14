package com.example.plugin_mappintelligence

import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import androidx.core.view.children
import io.flutter.plugins.webviewflutter.WebViewClientProxyApi
import io.flutter.plugins.webviewflutter.WebViewProxyApi

object Util {
    fun findAllWebViews(view: View): List<WebView> {
        val result = mutableListOf<WebView>()

        if (view is WebView) {
            result.add(view)
        } else if (view is ViewGroup) {
            for(child in view.children){
                result.addAll(findAllWebViews(child))
            }
        }

        return result
    }
}