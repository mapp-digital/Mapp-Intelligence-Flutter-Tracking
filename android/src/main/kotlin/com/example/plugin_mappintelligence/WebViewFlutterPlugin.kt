// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package com.example.plugin_mappintelligence

import com.example.plugin_mappintelligence.webviewflutter.FlutterCookieManager
import com.example.plugin_mappintelligence.webviewflutter.WebViewFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

/**
 * Java platform implementation of the webview_flutter plugin.
 *
 *
 * Register this in an add to app scenario to gracefully handle activity and context changes.
 *
 *
 * Call [.registerWith] to use the stable `io.flutter.plugin.common`
 * package instead.
 */
public class WebViewFlutterPlugin
/**
 * Add an instance of this to [io.flutter.embedding.engine.plugins.PluginRegistry] to
 * register it.
 *
 *
 * THIS PLUGIN CODE PATH DEPENDS ON A NEWER VERSION OF FLUTTER THAN THE ONE DEFINED IN THE
 * PUBSPEC.YAML. Text input will fail on some Android devices unless this is used with at least
 * flutter/flutter@1d4d63ace1f801a022ea9ec737bf8c15395588b9. Use the V1 embedding with [ ][.registerWith] to use this plugin with older Flutter versions.
 *
 *
 * Registration should eventually be handled automatically by v2 of the
 * GeneratedPluginRegistrant. https://github.com/flutter/flutter/issues/42694
 */
    : FlutterPlugin {
    private var flutterCookieManager: FlutterCookieManager? = null
    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        val messenger = binding.binaryMessenger
        binding
            .platformViewRegistry
            .registerViewFactory(
                "plugin_mappintelligence/webview",
                WebViewFactory(messenger,  /*containerView=*/null)
            )
        flutterCookieManager = FlutterCookieManager(messenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        if (flutterCookieManager == null) {
            return
        }
        flutterCookieManager!!.dispose()
        flutterCookieManager = null
    }
}