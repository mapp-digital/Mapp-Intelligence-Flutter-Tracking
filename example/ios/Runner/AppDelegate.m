#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <Photos/Photos.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  [GeneratedPluginRegistrant registerWithRegistry:self];

  FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
  FlutterMethodChannel* nativeChannel = [FlutterMethodChannel
      methodChannelWithName:@"com.example/native"
            binaryMessenger:controller.binaryMessenger];

  [nativeChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    if ([@"askPhotoPermission" isEqualToString:call.method]) {
      [self requestPhotoPermission];
      result(nil);
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

       - (void)requestPhotoPermission {
         PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
         if (status == PHAuthorizationStatusNotDetermined) {
           [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {
             if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
               NSLog(@"Access granted to photo library.");
             } else {
               NSLog(@"Access denied to photo library.");
             }
           }];
         }
       }
@end
