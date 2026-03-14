//
//  TikTokEventsPlugin.m
//  TikTok Events SDK - Cordova Plugin
//
//  Created by ADS4U Digital
//

#import "TikTokEventsPlugin.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
@import TikTokBusinessSDK;

@interface TikTokEventsPlugin ()
@property (nonatomic, assign) BOOL sdkInitialized;
@property (nonatomic, assign) BOOL debugEnabled;
@end

@implementation TikTokEventsPlugin

- (void)pluginInitialize {
    [super pluginInitialize];
    self.sdkInitialized = NO;
    self.debugEnabled = NO;
}

#pragma mark - Initialization

- (void)initialize:(CDVInvokedUrlCommand*)command {
    NSDictionary *options = [command.arguments objectAtIndex:0];
    
    // Hole die IDs aus den Options oder Plugin-Variablen
    NSString *accessToken = options[@"accessToken"];
    NSString *appId = options[@"appId"];
    NSString *tiktokAppId = options[@"tiktokAppId"];
    
    // Fallback auf Plugin-Variablen aus config.xml (Cordova konvertiert zu lowercase)
    if (!accessToken || [accessToken length] == 0) {
        accessToken = [self.commandDelegate.settings objectForKey:@"tiktokaccesstoken"];
    }
    if (!appId || [appId length] == 0) {
        appId = [self.commandDelegate.settings objectForKey:@"tiktokappid"];
    }
    if (!tiktokAppId || [tiktokAppId length] == 0) {
        tiktokAppId = [self.commandDelegate.settings objectForKey:@"tiktoktiktokappid"];
    }
    
    if (self.debugEnabled) {
        NSLog(@"[TikTokEvents] Config - accessToken: %@, appId: %@, tiktokAppId: %@", 
              accessToken ? @"SET" : @"MISSING",
              appId ? @"SET" : @"MISSING", 
              tiktokAppId ? @"SET" : @"MISSING");
    }
    
    // Validierung
    if (!accessToken || [accessToken length] == 0) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR 
                                                    messageAsString:@"accessToken is required"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    if (!appId || [appId length] == 0) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR 
                                                    messageAsString:@"appId is required"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    if (!tiktokAppId || [tiktokAppId length] == 0) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR 
                                                    messageAsString:@"tiktokAppId is required"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    // Debug mode
    BOOL debug = [options[@"debug"] boolValue];
    self.debugEnabled = debug;
    
    // Configure SDK
    TikTokConfig *config = [TikTokConfig configWithAccessToken:accessToken
                                                         appId:appId
                                                   tiktokAppId:tiktokAppId];
    
    if (debug) {
        [config enableDebugMode];
        [config setLogLevel:TikTokLogLevelDebug];
    }
    
    // Initialize SDK
    @try {
        [TikTokBusiness initializeSdk:config completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                self.sdkInitialized = YES;
                
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
                                                            messageAsString:@"SDK initialized successfully"];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                
                if (self.debugEnabled) {
                    NSLog(@"[TikTokEvents] SDK initialized successfully");
                }
            } else {
                NSString *errorMsg = error ? error.localizedDescription : @"Unknown error";
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR 
                                                            messageAsString:errorMsg];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
        }];
    } @catch (NSException *exception) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR 
                                                    messageAsString:exception.reason];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void)requestTrackingAuthorization:(CDVInvokedUrlCommand*)command {
    [TikTokBusiness requestTrackingAuthorizationWithCompletionHandler:^(NSUInteger status) {
        NSString *statusString;
        switch (status) {
            case 3: // ATTrackingManagerAuthorizationStatusAuthorized
                statusString = @"authorized";
                break;
            case 2: // ATTrackingManagerAuthorizationStatusDenied
                statusString = @"denied";
                break;
            case 1: // ATTrackingManagerAuthorizationStatusRestricted
                statusString = @"restricted";
                break;
            case 0: // ATTrackingManagerAuthorizationStatusNotDetermined
            default:
                statusString = @"notDetermined";
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
                                                        messageAsString:statusString];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        });
    }];
}

#pragma mark - Event Tracking

- (void)trackEvent:(CDVInvokedUrlCommand*)command {
    if (!self.sdkInitialized) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR 
                                                    messageAsString:@"SDK not initialized. Call initialize() first."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    NSString *eventName = [command.arguments objectAtIndex:0];
    NSDictionary *properties = [command.arguments objectAtIndex:1];
    
    if (!eventName || [eventName length] == 0) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR 
                                                    messageAsString:@"eventName is required"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    @try {
        // Erstelle TikTokBaseEvent
        TikTokBaseEvent *event = [[TikTokBaseEvent alloc] initWithEventName:eventName];
        
        // Properties hinzufügen
        if (properties && [properties count] > 0) {
            for (NSString *key in properties) {
                [event addPropertyWithKey:key value:properties[key]];
            }
        }
        
        // Event tracken
        [TikTokBusiness trackTTEvent:event];
        
        if (self.debugEnabled) {
            NSLog(@"[TikTokEvents] Tracked event: %@ with properties: %@", eventName, properties);
        }
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } @catch (NSException *exception) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR 
                                                    messageAsString:exception.reason];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

#pragma mark - User Identity

- (void)identifyUser:(CDVInvokedUrlCommand*)command {
    if (!self.sdkInitialized) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR 
                                                    messageAsString:@"SDK not initialized. Call initialize() first."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    NSDictionary *userInfo = [command.arguments objectAtIndex:0];
    
    @try {
        NSString *externalId = userInfo[@"externalId"];
        NSString *externalUserName = userInfo[@"externalUserName"];
        NSString *phoneNumber = userInfo[@"phone"];
        NSString *email = userInfo[@"email"];
        
        [TikTokBusiness identifyWithExternalID:externalId
                              externalUserName:externalUserName
                                   phoneNumber:phoneNumber
                                         email:email];
        
        if (self.debugEnabled) {
            NSLog(@"[TikTokEvents] User identified");
        }
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } @catch (NSException *exception) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR 
                                                    messageAsString:exception.reason];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void)clearUser:(CDVInvokedUrlCommand*)command {
    if (!self.sdkInitialized) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR 
                                                    messageAsString:@"SDK not initialized. Call initialize() first."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    @try {
        [TikTokBusiness logout];
        
        if (self.debugEnabled) {
            NSLog(@"[TikTokEvents] User logged out");
        }
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } @catch (NSException *exception) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR 
                                                    messageAsString:exception.reason];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

#pragma mark - Utility

- (void)getVersion:(CDVInvokedUrlCommand*)command {
    NSString *version = [TikTokBusiness getSDKVersion];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
                                                messageAsString:version];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)isInitialized:(CDVInvokedUrlCommand*)command {
    BOOL initialized = [TikTokBusiness isInitialized];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
                                                  messageAsBool:initialized];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)setDebug:(CDVInvokedUrlCommand*)command {
    BOOL enabled = [[command.arguments objectAtIndex:0] boolValue];
    self.debugEnabled = enabled;
    
    if (enabled) {
        NSLog(@"[TikTokEvents] Debug logging enabled");
    }
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
