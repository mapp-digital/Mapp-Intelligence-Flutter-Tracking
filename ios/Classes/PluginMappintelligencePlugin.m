#import "PluginMappintelligencePlugin.h"
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>

@interface PluginMappintelligencePlugin ()
@property WKWebView* webView;
@end

@implementation PluginMappintelligencePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"plugin_mappintelligence"
            binaryMessenger:[registrar messenger]];
  PluginMappintelligencePlugin* instance = [[PluginMappintelligencePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"initialize" isEqualToString:call.method]) {
    NSArray<NSNumber *>* array = call.arguments[@"trackIds"];
    NSString *domain = call.arguments[@"trackDomain"];
    NSLog(@"ids: %@ und domain: %@", array, domain);
    [[MappIntelligence shared] initWithConfiguration:array onTrackdomain:domain];
    result(@"Succesfull initialize");
  } else if ([@"setLogLevel" isEqualToString: call.method]) {
    NSNumber* logLevelNumber = call.arguments[0];
    NSLog(@"Flutter: logLevel: %@", logLevelNumber);
    [[MappIntelligence shared] setLogLevel:[logLevelNumber intValue]];
  } else if ([@"setBatchSupportEnabled" isEqualToString: call.method]) {
    NSNumber* isEnabled = call.arguments[0];
    NSLog(@"Flutter set batch support: %@", isEnabled);
    [[MappIntelligence shared] setBatchSupportEnabled:[isEnabled boolValue]];
  } else if ([@"setBatchSupportSize" isEqualToString: call.method]) {
    NSNumber* size = call.arguments[0];
    NSLog(@"Flutter batch support size: %@", size);
    [[MappIntelligence shared] setBatchSupportSize:[size intValue]];
  } else if ([@"setRequestInterval" isEqualToString: call.method]) {
    NSNumber* interval = call.arguments[0];
    NSLog(@"Flutter interval: %@", interval);
    [[MappIntelligence shared] setRequestInterval:[interval intValue]];
  } else if ([@"setRequestPerQueue" isEqualToString: call.method]) {
    NSNumber* requestsNumber = call.arguments[0];
    NSLog(@"Flutter requests number: %@", requestsNumber);
    [[MappIntelligence shared] setRequestPerQueue:[requestsNumber intValue]];
  } else if ([@"OptIn" isEqualToString: call.method]) {
    NSLog(@"Flutter: opt in is done!");
    [[MappIntelligence shared] optIn];
  } else if ([@"optOutAndSendCurrentData" isEqualToString: call.method]) {
    NSNumber* isEnabled = call.arguments[0];  
    NSLog(@"Flutter will save and send old data: %@", isEnabled);
    [[MappIntelligence shared] optOutAndSendCurrentData:[isEnabled boolValue]];
  } else if ([@"reset" isEqualToString: call.method]) {
    NSLog(@"Flutter: Reset is done!");
    [[MappIntelligence shared] reset];
  } else if ([@"enableAnonymousTracking" isEqualToString: call.method]) {
    NSNumber* isEnabled = call.arguments[0];  
    NSLog(@"Flutter enable Anonymous Tracking: %@", isEnabled);
    [[MappIntelligence shared] setAnonymousTracking: [isEnabled boolValue]];
  } else if ([@"enableAnonymousTrackingWithParameters" isEqualToString: call.method]) {
    NSArray<NSString *>* supressedParameters = call.arguments[0];
    NSLog(@"Flutter enable Anonymous Tracking with supressed parameters: %@", supressedParameters);
    [[MappIntelligence shared] enableAnonymousTracking:supressedParameters];
  } else if ([@"isAnonymousTrackingEnabled" isEqualToString: call.method]) {
    NSNumber* isEnabled = [NSNumber numberWithBool:[[MappIntelligence shared] anonymousTracking]];
    NSLog(@"Flutter: is anonymus trackint enabled: %@", isEnabled);
    result(isEnabled);
  } else if ([@"trackPage" isEqualToString: call.method]) {
    NSString* pageName = call.arguments[0];
    [[MappIntelligence shared] trackCustomPage:pageName trackingParams:nil];
  } else if ([@"trackCustomPage" isEqualToString: call.method]) {
    NSString* pageName = call.arguments[0];
    NSDictionary* pageParameters = call.arguments[1];
    [[MappIntelligence shared] trackCustomPage:pageName trackingParams:pageParameters];
  } else if ([@"trackPageWithCustomData" isEqualToString: call.method]) {

    NSString* jsonString = call.arguments[0];
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    
    MIPageParameters* pageProperties = s[@"pageParameters"];
    NSLog(@"\npage:%@", pageProperties);
    MICampaignParameters* campaignParameters = s[@"campaignParameters"];
    NSLog(@"\ncampaign:%@", campaignParameters);
    MISessionParameters* sessionProperties = s[@"sessionParameters"];
    NSLog(@"\nsession:%@", sessionProperties);
    MIUserCategories* userCategories = s[@"userCategories"];
    NSLog(@"\nuser:%@", userCategories);
    MIEcommerceParameters* ecommerceProperties = s[@"ecommerceParameters"];
    NSLog(@"\necommerce:%@", ecommerceProperties);
    NSString* eventName = s[@"name"];
    NSLog(@"\neventName:%@", eventName);

    MIPageViewEvent* event = [[MIPageViewEvent alloc] init];
    [event setPageName:eventName];
    [event setPageParameters:pageProperties];
    [event setUserCategories:userCategories];
    [event setSessionParameters:sessionProperties];
    [event setCampaignParameters:campaignParameters];
    [event setEcommerceParameters:ecommerceProperties];
    NSLog(@"\nevent:%@", event);
    //TODO: it will need to be done with new initializators with dictionary
    //[[MappIntelligence shared] trackPage: event];
  } else if ([@"trackAction" isEqualToString: call.method]) {
    NSString* jsonString = call.arguments[0];
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary * s = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    NSLog(@"\ndictionary for track action:%@", s);
    //TODO: mapp with dictionary and new lib 
  } else if ([@"trackUrl" isEqualToString: call.method]) {
    NSString* urlString = call.arguments[0];
    NSString* mediaCode = call.arguments[1];
    NSURL* url = [[NSURL alloc] initWithString:urlString];
    [[MappIntelligence shared] trackUrl:url withMediaCode:mediaCode];

  } else if ([@"trackUrlWitouthMediaCode" isEqualToString: call.method]) {
    NSString* urlString = call.arguments[0];
    NSURL* url = [[NSURL alloc] initWithString:urlString];
    [[MappIntelligence shared] trackUrl:url withMediaCode:NULL];
  } else if ([@"trackMedia" isEqualToString: call.method]) {
    NSString* jsonString = call.arguments[0];
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    NSLog(@"\ndictionary for track media:%@", s);
    //TODO: mapp with dictionary and new lib 

  } else if ([@"trackWebview" isEqualToString: call.method]) {
    NSNumber* x =  call.arguments[0];
    NSNumber* y = call.arguments[1];
    NSNumber* width = call.arguments[2];
    NSNumber* height = call.arguments[3];
    NSString* urlString = call.arguments[4];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
      WKWebViewConfiguration* configuration = [[WKWebViewConfiguration alloc] init];
      [[MIWebViewTracker sharedInstance] updateConfiguration:configuration];
        UIViewController* base = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        UIViewController* topViewController = [self topViewController:base];
        
        if(topViewController) {
            self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(x.doubleValue, y.doubleValue, width.doubleValue, height.doubleValue) configuration:configuration];
            [[topViewController view] addSubview:self.webView];
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:urlString]];
            [self.webView loadRequest:request];
        }
    });
  } else if ([@"disposeWebview" isEqualToString: call.method]) {
    if (self.webView) {
        self.webView.removeFromSuperview;
    }
    self.webView = NULL;
  }
  else { 
    result(FlutterMethodNotImplemented);
  }
}

-(UIViewController* ) topViewController: (UIViewController* ) base {
    if ([base isKindOfClass:UINavigationController.class]) {
        UINavigationController* nav  = (UINavigationController*) base;
        return [self topViewController:[nav visibleViewController]];
    }
    if ([base isKindOfClass:UITabBarController.class]) {
        UITabBarController* tab = (UITabBarController*) base;
        UIViewController* selected = [tab selectedViewController];
        if (selected) {
            return [self topViewController:selected];
        }
    }
    UIViewController* presented = [base presentedViewController];
    if (presented) {
        return [self topViewController:presented];
    }
    return base;
}

@end
