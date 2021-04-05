#import "PluginMappintelligencePlugin.h"

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
    // page properties
    NSString* searchTerm = call.arguments[0];
    NSDictionary* categories = call.arguments[1];
    NSDictionary* params = call.arguments[2];
    MIPageParameters* pageProperties = [[MIPageParameters alloc] initWithPageParams:params pageCategory:categories search:searchTerm];
    
    
    MIPageViewEvent* pageViewEvent = [[MIPageViewEvent alloc] initWithName:@"testName"];
    [pageViewEvent setPageParameters:pageProperties];
    [[MappIntelligence shared] trackPage:pageViewEvent];
  }
  else { 
    result(FlutterMethodNotImplemented);
  }
}

@end
