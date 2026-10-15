#import "SceneDelegate.h"

#import <Flutter/Flutter.h>
#import <Photos/Photos.h>

@implementation SceneDelegate

- (void)scene:(UIScene *)scene
    willConnectToSession:(UISceneSession *)session
                 options:(UISceneConnectionOptions *)connectionOptions {
  FlutterViewController *controller =
      (FlutterViewController *)self.window.rootViewController;
  FlutterMethodChannel *nativeChannel = [FlutterMethodChannel
      methodChannelWithName:@"com.example/native"
            binaryMessenger:controller.binaryMessenger];

  [nativeChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
    if ([@"askPhotoPermission" isEqualToString:call.method]) {
      [self requestPhotoPermission];
      result(nil);
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];
}

- (void)requestPhotoPermission {
  PHAuthorizationStatus status =
      [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
  if (status == PHAuthorizationStatusNotDetermined) {
    [PHPhotoLibrary
        requestAuthorizationForAccessLevel:PHAccessLevelReadWrite
                                   handler:^(PHAuthorizationStatus status) {
      if (status == PHAuthorizationStatusAuthorized ||
          status == PHAuthorizationStatusLimited) {
        NSLog(@"Access granted to photo library.");
      } else {
        NSLog(@"Access denied to photo library.");
      }
    }];
  }
}

@end
