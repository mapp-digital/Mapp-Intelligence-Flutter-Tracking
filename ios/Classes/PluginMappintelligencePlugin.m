#import "PluginMappintelligencePlugin.h"
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>
#import "MappIntelligence.h"
#import "MIWebViewTracker.h"
#import "MIDefaultTracker.h"

@interface PluginMappintelligencePlugin ()
@property WKWebView* webView;
@end

static NSString *domainString = nil;
static NSArray<NSNumber *>* trackIDs = nil;
static NSNumber* logLevelGlobal = nil;

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
  }else if ([@"build" isEqualToString:call.method]) {
    result(@"success");
//do nothing, that method is only used for Android
  } else if ([@"initialize" isEqualToString:call.method]) {
    NSArray<NSString *>* array = call.arguments[@"trackIds"];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSMutableArray<NSNumber*>* newArray = [[NSMutableArray alloc] init];
    for (NSString* object in array ) {
      [newArray addObject:[f numberFromString:object]];
    }
    NSString *domain = call.arguments[@"trackDomain"];
    domainString = domain;
    trackIDs = newArray;
    [[MappIntelligence shared] initWithConfiguration:newArray onTrackdomain:domain];
    result(@"Succesfull initialize");
  } else if ([@"setLogLevel" isEqualToString: call.method]) {
    NSNumber* logLevelNumber = call.arguments[0];
    logLevelGlobal = logLevelNumber;
    [[MappIntelligence shared] setLogLevel:[logLevelNumber intValue]];
    result(@"log level set successfull");
  } else if ([@"setBatchSupportEnabledWithSize" isEqualToString: call.method]) {
    NSNumber* isEnabled = call.arguments[0];
    NSNumber* size = call.arguments[1];
    [[MappIntelligence shared] setBatchSupportEnabled:[isEnabled boolValue]];
    [[MappIntelligence shared] setBatchSupportSize:[size intValue]];
    result(@"batch support set successfull");
  } else if ([@"setRequestInterval" isEqualToString: call.method]) {
    NSNumber* interval = call.arguments[0];
    [[MappIntelligence shared] setRequestInterval:[interval intValue]];
    result(@"request interval set successfull");
  } else if ([@"setRequestPerQueue" isEqualToString: call.method]) {
    NSNumber* requestsNumber = call.arguments[0];
    [[MappIntelligence shared] setRequestPerQueue:[requestsNumber intValue]];
    result(@"requests per queue set successfull");
  } else if ([@"OptIn" isEqualToString: call.method]) {
    [[MappIntelligence shared] optIn];
    result(@"success");
  } else if ([@"optOutAndSendCurrentData" isEqualToString: call.method]) {
    NSNumber* isEnabled = call.arguments[0];  
    [[MappIntelligence shared] optOutAndSendCurrentData:[isEnabled boolValue]];
    result(@"success");
  } else if ([@"reset" isEqualToString: call.method]) {
    [[MappIntelligence shared] reset];
    result(@"success");
  } 
  // else if ([@"enableAnonymousTracking" isEqualToString: call.method]) {
  //   NSNumber* isEnabled = call.arguments[0];  
  //   [[MappIntelligence shared] setAnonymousTracking: [isEnabled boolValue]];
  // } else if ([@"enableAnonymousTrackingWithParameters" isEqualToString: call.method]) {
  //   NSArray<NSString *>* supressedParameters = call.arguments[0];
  //   [[MappIntelligence shared] enableAnonymousTracking:supressedParameters];
  // } 
  else if ([@"enableAnonymousTracking" isEqualToString: call.method]) {
    NSNumber* isEnabled = call.arguments[@"anonymousTracking"];  
    NSArray<NSString *>* supressedParameters = call.arguments[@"params"];
    if([isEnabled boolValue] && supressedParameters != [NSNull null]) {
      [[MappIntelligence shared] enableAnonymousTracking:supressedParameters];
    } else {
      [[MappIntelligence shared] setAnonymousTracking: [isEnabled boolValue]];
    }
    NSNumber* generateNewEverID = call.arguments[@"generateNewEverId"];
    if(generateNewEverID) {
      NSLog(@"generate new id: %@", generateNewEverID);
      if ([generateNewEverID boolValue] && ![isEnabled boolValue]) {
        [[MIDefaultTracker sharedDefaults] removeObjectForKey:@"everId"];
        [[MIDefaultTracker sharedInstance] generateEverId];
        [self updateInit: [[MIDefaultTracker sharedDefaults] stringForKey:@"everId"]];
      } 
    }
    result(@"success");
  } else if ([@"isAnonymousTrackingEnabled" isEqualToString: call.method]) {
    NSNumber* isEnabled = [NSNumber numberWithBool:[[MappIntelligence shared] anonymousTracking]];
    result(isEnabled);
  } else if ([@"trackPage" isEqualToString: call.method]) {
    NSLog(@"page is tracked objc flutter");
    NSString* pageName = call.arguments[0];
    MIPageViewEvent* event = [[MIPageViewEvent alloc] init];
    event.pageName = pageName;
    [[MappIntelligence shared] trackPage:event];
    result(@"success");
  } else if ([@"trackCustomPage" isEqualToString: call.method]) {
    NSString* pageName = call.arguments[0];
    NSDictionary* pageParameters = call.arguments[1];
    [[MappIntelligence shared] trackCustomPage:pageName trackingParams:pageParameters];
    result(@"success");
  } else if ([@"trackPageWithCustomNameAndPageViewEvent" isEqualToString: call.method]) {
    NSString* pageName = call.arguments[0];
    MIPageViewEvent* event = [[MIPageViewEvent alloc] init];
    event.pageName = pageName;
    [[MappIntelligence shared] trackPage:event];
    result(@"success");
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
        [campaignActionParameters setAction:[self getCampaignAction:@([dict[@"action"] longValue])]];
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
        [userActionCategories setGender:[self getGender:@([dict[@"gender"] longValue])]];
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
    [[MappIntelligence shared] trackPage: event];
    result(@"success");
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
        [campaignActionParameters setAction:[self getCampaignAction:@([dict[@"action"] longValue])]];
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
        [userActionCategories setGender:[self getGender:@([dict[@"gender"] longValue])]];
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
    result(@"success");
  } else if ([@"trackUrl" isEqualToString: call.method]) {
    NSString* urlString = call.arguments[0];
    NSString* mediaCode = call.arguments[1];
    NSURL* url = [[NSURL alloc] initWithString:urlString];
    [[MappIntelligence shared] trackUrl:url withMediaCode:mediaCode];
    result(@"success");
  } else if ([@"trackUrlWithoutMediaCode" isEqualToString: call.method]) {
    NSString* urlString = call.arguments[0];
    NSURL* url = [[NSURL alloc] initWithString:urlString];
    [[MappIntelligence shared] trackUrl:url withMediaCode:NULL];
    result(@"success");
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
    result(@"success");
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
    result(@"success");
  } else if ([@"disposeWebview" isEqualToString: call.method]) {
    if (self.webView) {
        self.webView.removeFromSuperview;
    }
    self.webView = NULL;
    result(@"success");
  } else if ([@"getEverId" isEqualToString: call.method]) {
    result([[MappIntelligence shared] getEverId]);
  } else if ([@"setEverId" isEqualToString: call.method]) {
    NSString* everID = call.arguments[0];
    [self updateInit: everID];
    result(@"success");
  } else if ([@"resetConfig" isEqualToString: call.method]) {
    [[MappIntelligence shared] reset];
    result(@"success");
  } else if ([@"setIdsAndDomain" isEqualToString: call.method]) {
    NSArray<NSString *>* array = call.arguments[@"trackIds"];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSMutableArray<NSNumber*>* newArray = [[NSMutableArray alloc] init];
    for (NSString* object in array ) {
      [newArray addObject:[f numberFromString:object]];
    }
    NSString *domain = call.arguments[@"trackDomain"];
    domainString = domain;
    trackIDs = newArray;
    [[MappIntelligence shared] setIdsAndDomain:newArray onTrackdomain:domain];
    result(@"success");
  } else if ([@"setSendAppVersionInEveryRequest" isEqualToString: call.method]) {
    NSNumber* isEnabled = call.arguments[0];
    [[MappIntelligence shared] setSendAppVersionInEveryRequest:[isEnabled boolValue]];
    result(@"success");
  } else if ([@"enableCrashTracking" isEqualToString: call.method]) {
    NSNumber* isEnabled = call.arguments[0];
    NSLog(@"crash level is %@", isEnabled);
    [[MappIntelligence shared] enableCrashTracking:[isEnabled intValue] + 1];
    result(@"success");
  } else if ([@"trackExceptionWithNameAndMessage" isEqualToString: call.method]) {
    NSString* exceptionName = call.arguments[@"name"];
    NSString* exceptionMessage = call.arguments[@"message"];
    [[MappIntelligence shared] trackExceptionWithName:exceptionName andWithMessage:exceptionMessage];
    result(@"success");
  } else if ([@"raiseUncaughtException" isEqualToString: call.method]) {
    NSException *exception = [NSException exceptionWithName:@"Custom Exception" reason:@"Custom Reason" userInfo:@{@"Localized key": @"Unexpected Input"}];
    [exception raise];
    result(@"success");
  } else if ([@"trackError" isEqualToString: call.method]) {
    NSDictionary* userInfoDict = call.arguments[@"userInfo"];
    NSNumber* code = call.arguments[@"code"];
    NSString* domain = call.arguments[@"domain"];

    NSError *error = [[NSError alloc] initWithDomain:domain code:code userInfo:@{ NSLocalizedFailureReasonErrorKey:userInfoDict[@"fauilureReason"] ? userInfoDict[@"fauilureReason"] : @"",
            NSLocalizedDescriptionKey:userInfoDict[@"description"] ? userInfoDict[@"description"] : @""
    }];
    [[MappIntelligence shared] trackExceptionWith:error];
    result(@"success");
  } else if ([@"setUserMatchingEnabled" isEqualToString: call.method]) {
    NSNumber* isEnabled = call.arguments[@"enabled"];
    [[MappIntelligence shared] setEnableUserMatching:[isEnabled boolValue]];
    result(@"success");
  } else if ([@"sendAndCleanData" isEqualToString: call.method]) {
    [[MIDefaultTracker sharedInstance] sendRequestFromDatabaseWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"error: %@", error);
        }
    }];
    result(@"success");
  } else if ([@"getCurrentConfig" isEqualToString: call.method]) {
     [[MappIntelligence shared] setBatchSupportEnabled:[[MappIntelligence shared] batchSupportEnabled]]; 
    result([[NSDictionary alloc] init]);
  } else if ([@"updateCustomParams" isEqualToString: call.method]) {
    NSString* version = call.arguments[0];
    [[MIDefaultTracker sharedInstance] setPlatform:@"Flutter"];
    [[MIDefaultTracker sharedInstance] setVersion:version]; 
    result(@"success");
  } else if ([@"printUsageStatisticsCalculationLog" isEqualToString: call.method]) {
    [[[MIDefaultTracker sharedInstance] usageStatistics] printUserStatistics]; 
    result(@"success");
  } else if ([@"setTemporarySessionId" isEqualToString: call.method]) {
    NSString* temporarryID = call.arguments[@"temporarySessionId"];
    if([temporarryID  isEqual: @""]) {
        NSLog(@"temporarry user ID can not be empty string!");
        result(@"success");
        return;
    } else {
      [[MappIntelligence shared] setTemporarySessionId:temporarryID];
    }
    result(@"success");
  } else { 
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

-(void)updateInit: (NSString* ) everID {
    if (trackIDs && domainString) {
      ([[MappIntelligence shared] initWithConfiguration:trackIDs onTrackdomain:domainString andWithEverID:everID]);
    } else {
      NSLog(@"Domain and track id must be setup before set ever ID method!");
    }
    if (logLevelGlobal) {
      [[MappIntelligence shared] setLogLevel:[logLevelGlobal intValue]];
    }
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
        case 4:
            return deletedFromBasket;
            break;
        case 5:
            return addedToWishlist;
            break;
        case 6:
            return deletedFromWishlist;
            break;
        case 7:
            return checkout;
            break;
        default:
            return viewed;
            break;
    }
    return viewed;
}

-(MIGender)getGender: (NSNumber*)gender {
  int genderValue = [gender intValue];
  if (!genderValue) {
    return unknown;
  }
    switch (genderValue) {
        case 0:
            return unknown;
            break;
        case 1:
            return male;
            break;
        case 2:
            return female;
            break;
        default:
            return unknown;
            break;
    }
    return unknown;
}

-(MICampaignAction)getCampaignAction: (NSNumber*)campaignAction {
    switch ([campaignAction intValue]) {
        case 0:
            return click;
            break;
        case 1:
            return view;
            break;
        default:
            return view;
            break;
    }
    return view;
}

@end
