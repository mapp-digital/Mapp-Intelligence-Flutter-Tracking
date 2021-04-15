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
    NSLog(@"iOS native: logLevel: %@", call.arguments[0]);
    NSNumber* logLevelNumber = call.arguments[0];
    [[MappIntelligence shared] setLogLevel:[logLevelNumber intValue]];
  } else if ([@"setBatchSupportEnabledWithSize" isEqualToString: call.method]) {
    NSNumber* isEnabled = call.arguments[0];
    NSNumber* size = call.arguments[1];
    NSLog(@"Flutter set batch support: %@", isEnabled);
    NSLog(@"Flutter batch support size: %@", size);
    [[MappIntelligence shared] setBatchSupportEnabled:[isEnabled boolValue]];
    [[MappIntelligence shared] setBatchSupportSize:[size intValue]];
  } else if ([@"setRequestInterval" isEqualToString: call.method]) {
    NSNumber* interval = call.arguments[0];
    NSLog(@"Flutter interval: %@", interval);
    [[MappIntelligence shared] setRequestInterval:[interval intValue]*60];
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
  } else if ([@"trackPageWithCustomNameAndPageViewEvent" isEqualToString: call.method]) {
    NSString* pageName = call.arguments[0];
    MIPageViewEvent* event = [[MIPageViewEvent alloc] init];
    event.pageName = pageName;
    [[MappIntelligence shared] trackPage:event];
  } else if ([@"trackPageWithCustomData" isEqualToString: call.method]) {

    NSString* jsonString = call.arguments[0];
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    s = [self removeNullsFromDictionary:s];
    MIPageViewEvent* event = [[MIPageViewEvent alloc] initWithName:s[@"name"]];
    
    if(s[@"pageParameters"]) {
        NSMutableDictionary* dict = [self removeNullsFromDictionary:s[@"pageParameters"]];
        MIPageParameters* pageParameters = [[MIPageParameters alloc] initWithDictionary:dict];
        [event setPageParameters:pageParameters];
    }
    if(s[@"campaignParameters"]) {
        NSMutableDictionary* dict = [self removeNullsFromDictionary:s[@"campaignParameters"]];
        MICampaignParameters* campaignActionParameters = [[MICampaignParameters alloc] initWithDictionary:dict];
        [event setCampaignParameters:campaignActionParameters];
    }
    if (s[@"sessionParameters"]) {
        NSMutableDictionary* dict = [self removeNullsFromDictionary:s[@"sessionParameters"]];
        MISessionParameters* sessionActionProperties = [[MISessionParameters alloc] initWithDictionary:dict];
        [event setSessionParameters:sessionActionProperties];
    }
    if(s[@"userCategories"]) {
        NSMutableDictionary* dict = [self removeNullsFromDictionary:s[@"userCategories"]];
        MIUserCategories* userActionCategories = [[MIUserCategories alloc] initWithDictionary:dict];
        [event setUserCategories:userActionCategories];
    }
    if (s[@"ecommerceParameters"]) {
        NSMutableDictionary* dict = [self removeNullsFromDictionary:s[@"ecommerceParameters"]];
        NSArray<NSDictionary*>* products = dict[@"products"];
        if (products) {
            dict[@"products"] = [self nullCheckedProducts:products];
        }
        MIEcommerceParameters* ecommerceActionProperties = [[MIEcommerceParameters alloc] initWithDictionary:dict];
        ecommerceActionProperties.status = [self getStatus:@([dict[@"status"] longValue])];
        [event setEcommerceParameters:ecommerceActionProperties];
    }
    NSLog(@"\nevent:%@", event);
    [[MappIntelligence shared] trackPage: event];
  } else if ([@"trackAction" isEqualToString: call.method]) {
    NSString* jsonString = call.arguments[0];
    NSData* actionData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary * actionS = [NSJSONSerialization JSONObjectWithData:actionData options:0 error:NULL];
    actionS = [self removeNullsFromDictionary:actionS];
    MIActionEvent* actionEvent = [[MIActionEvent alloc] initWithName:actionS[@"name"]];
    
    if(actionS[@"eventParameters"]) {
        NSMutableDictionary* dict = [self removeNullsFromDictionary:actionS[@"eventParameters"]];
        MIEventParameters* eventParameters = [[MIEventParameters alloc] initWithDictionary:dict];
        [actionEvent setEventParameters:eventParameters];
    }
    if(actionS[@"campaignParameters"]) {
        NSMutableDictionary* dict = [self removeNullsFromDictionary:actionS[@"campaignParameters"]];
        MICampaignParameters* campaignActionParameters = [[MICampaignParameters alloc] initWithDictionary:dict];
        [actionEvent setCampaignParameters:campaignActionParameters];
    }
    if (actionS[@"sessionParameters"]) {
        NSMutableDictionary* dict = [self removeNullsFromDictionary:actionS[@"sessionParameters"]];
        MISessionParameters* sessionActionProperties = [[MISessionParameters alloc] initWithDictionary:dict];
        [actionEvent setSessionParameters:sessionActionProperties];
    }
    if(actionS[@"userCategories"]) {
        NSMutableDictionary* dict = [self removeNullsFromDictionary:actionS[@"userCategories"]];
        MIUserCategories* userActionCategories = [[MIUserCategories alloc] initWithDictionary:dict];
        [actionEvent setUserCategories:userActionCategories];
    }
    if (actionS[@"ecommerceParameters"]) {
        NSMutableDictionary* dict = [self removeNullsFromDictionary:actionS[@"ecommerceParameters"]];
        NSArray<NSDictionary*>* products = dict[@"products"];
        if (products) {
            dict[@"products"] = [self nullCheckedProducts:products];
        }
        MIEcommerceParameters* ecommerceActionProperties = [[MIEcommerceParameters alloc] initWithDictionary:dict];
        ecommerceActionProperties.status = [self getStatus:@([dict[@"status"] longValue])];
        [actionEvent setEcommerceParameters:ecommerceActionProperties];
    }
    
    [[MappIntelligence shared] trackAction:actionEvent];

  } else if ([@"trackUrl" isEqualToString: call.method]) {
    NSString* urlString = call.arguments[0];
    NSString* mediaCode = call.arguments[1];
    NSURL* url = [[NSURL alloc] initWithString:urlString];
    [[MappIntelligence shared] trackUrl:url withMediaCode:mediaCode];

  } else if ([@"trackUrlWithoutMediaCode" isEqualToString: call.method]) {
    NSString* urlString = call.arguments[0];
    NSURL* url = [[NSURL alloc] initWithString:urlString];
    [[MappIntelligence shared] trackUrl:url withMediaCode:NULL];

  } else if ([@"trackMedia" isEqualToString: call.method]) {
    NSString* jsonString = call.arguments[0];
    NSData* mediaData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *mediaS = [NSJSONSerialization JSONObjectWithData:mediaData options:0 error:NULL];
    mediaS = [self removeNullsFromDictionary:mediaS];
    
    NSMutableDictionary* dict = [self removeNullsFromDictionary:mediaS[@"mediaParameters"]];
    MIMediaParameters* mediaParameters = [[MIMediaParameters alloc] initWithDictionary:dict];
    
    MIMediaEvent* mediaEvent = [[MIMediaEvent alloc] initWithPageName:mediaS[@"name"] parameters: mediaParameters];
    
    if(mediaS[@"eventParameters"]) {
        NSMutableDictionary* dict = [self removeNullsFromDictionary:mediaS[@"eventParameters"]];
        MIEventParameters* eventParameters = [[MIEventParameters alloc] initWithDictionary:dict];
        [mediaEvent setEventParameters:eventParameters];
    }
    if (mediaS[@"sessionParameters"]) {
        NSMutableDictionary* dict = [self removeNullsFromDictionary:mediaS[@"sessionParameters"]];
        MISessionParameters* sessionMediaProperties = [[MISessionParameters alloc] initWithDictionary:dict];
        [mediaEvent setSessionParameters:sessionMediaProperties];
    }
    if (mediaS[@"ecommerceParameters"]) {
        NSMutableDictionary* dict = [self removeNullsFromDictionary:mediaS[@"ecommerceParameters"]];
        NSArray<NSDictionary*>* products = dict[@"products"];
        if (products) {
            dict[@"products"] = [self nullCheckedProducts:products];
        }
        MIEcommerceParameters* ecommerceActionProperties = [[MIEcommerceParameters alloc] initWithDictionary:dict];
        ecommerceActionProperties.status = [self getStatus:@([dict[@"status"] longValue])];
        [mediaEvent setEcommerceParameters:ecommerceActionProperties];
    }
    
    [[MappIntelligence shared] trackMedia:mediaEvent];

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

-(NSMutableDictionary* )removeNullsFromDictionary: (NSDictionary* ) dict {
    NSMutableDictionary *prunedDictionary = [NSMutableDictionary dictionary];
    for (NSString * key in [dict allKeys])
    {
        if (![[dict objectForKey:key] isKindOfClass:[NSNull class]])
            [prunedDictionary setObject:[dict objectForKey:key] forKey:key];
    }
    return prunedDictionary;
}

-(NSMutableArray<NSDictionary*>*)nullCheckedProducts: (NSArray<NSDictionary*>*) products {
    NSMutableArray<NSDictionary*>* nullCheckedProducts = [[NSMutableArray alloc] init];
    for (NSDictionary* productDict in products) {
        NSDictionary* nullCheckedProduct = [self removeNullsFromDictionary:productDict];
        [nullCheckedProducts addObject:nullCheckedProduct];
    }
    return nullCheckedProducts;
}

-(MIStatus)getStatus: (NSNumber*)status {
    switch ([status intValue]) {
        case 0:
            return noneStatus;
            break;
        case 1:
            return addedToBasket;
            break;
        case 2:
            return purchased;
            break;
        case 3:
            return viewed;
            break;
            
        default:
            return viewed;
            break;
    }
    return viewed;
}

@end
