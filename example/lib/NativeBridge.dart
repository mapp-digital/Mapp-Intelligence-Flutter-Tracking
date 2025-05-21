import 'dart:io' show Platform;
import 'package:flutter/services.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('com.example/native');

  static Future<void> askPhotoPermission() async {
    if (Platform.isIOS) {
      try {
        await _channel.invokeMethod('askPhotoPermission');
      } on PlatformException catch (e) {
        print('Failed to get permission: ${e.message}');
      }
    }
  }
}
