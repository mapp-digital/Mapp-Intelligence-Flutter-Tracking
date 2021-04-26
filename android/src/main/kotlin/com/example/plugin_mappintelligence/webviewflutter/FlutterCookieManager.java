// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.plugin_mappintelligence.webviewflutter;

import android.os.Build;
import android.os.Build.VERSION_CODES;
import android.webkit.CookieManager;
import android.webkit.ValueCallback;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;


public class FlutterCookieManager implements MethodChannel.MethodCallHandler {
  private final MethodChannel methodChannel;

  public  FlutterCookieManager(BinaryMessenger messenger) {
    methodChannel = new MethodChannel(messenger, "plugin_mappintelligence/cookie_manager");
    methodChannel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
    switch (methodCall.method) {
      case "clearCookies":
        clearCookies(result);
        break;
      default:
        result.notImplemented();
    }
  }

  public void dispose() {
    methodChannel.setMethodCallHandler(null);
  }

  private static void clearCookies(final MethodChannel.Result result) {
    CookieManager cookieManager = CookieManager.getInstance();
    final boolean hasCookies = cookieManager.hasCookies();
    if (Build.VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
      cookieManager.removeAllCookies(
          new ValueCallback<Boolean>() {
            @Override
            public void onReceiveValue(Boolean value) {
              result.success(hasCookies);
            }
          });
    } else {
      cookieManager.removeAllCookie();
      result.success(hasCookies);
    }
  }
}
