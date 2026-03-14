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
    NSString *appId = options[@"appId"];
    
    // Fallback: App ID aus Plugin-Variable (config.xml)
    if (!appId || [appId length] == 0) {
        appId = [self.commandDelegate.settings objectForKey:@"tiktokappid"];
    }
    
    if (!appId || [appId length] == 0) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR 
                                                    messageAsString:@"appId is required. Pass it to initialize() or set TIKTOK_APP_ID during plugin install."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    // Configure SDK
    TikTokConfig *config = [TikTokConfig configWithAppId:appId];
    
    // Debug mode
    BOOL debug = [options[@"debug"] boolValue];
    if (debug) {
        self.debugEnabled = YES;
        config.logLevel = TikTokLogLevelDebug;
    } else {
        NSString *logLevel = options[@"logLevel"];
        if ([logLevel isEqualToString:@"debug"]) {
            config.logLevel = TikTokLogLevelDebug;
        } else if ([logLevel isEqualToString:@"info"]) {
            config.logLevel = TikTokLogLevelInfo;
        } else if ([logLevel isEqualToString:@"warn"]) {
            config.logLevel = TikTokLogLevelWarn;
        } else {
            config.logLevel = TikTokLogLevelNone;
        }
    }
    
    // Initialize SDK
    @try {
        [TikTokBusiness initializeSdk:config];
        self.sdkInitialized = YES;
        
        // Track app launch automatically
        [TikTokBusiness trackEvent:@"LaunchApp"];
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
                                                    messageAsString:@"SDK initialized successfully"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        
        if (self.debugEnabled) {
            NSLog(@"[TikTokEvents] SDK initialized with appId: %@", appId);
        }
    } @catch (NSException *exception) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR 
                                                    messageAsString:exception.reason];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void)requestTrackingAuthorization:(CDVInvokedUrlCommand*)command {
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            NSString *statusString;
            switch (status) {
                case ATTrackingManagerAuthorizationStatusAuthorized:
                    statusString = @"authorized";
                    break;
                case ATTrackingManagerAuthorizationStatusDenied:
                    statusString = @"denied";
                    break;
                case ATTrackingManagerAuthorizationStatusRestricted:
                    statusString = @"restricted";
                    break;
                case ATTrackingManagerAuthorizationStatusNotDetermined:
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
    } else {
        // Pre-iOS 14 - always authorized
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
                                                    messageAsString:@"authorized"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
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
        if (properties && [properties count] > 0) {
            [TikTokBusiness trackEvent:eventName withProperties:properties];
        } else {
            [TikTokBusiness trackEvent:eventName];
        }
        
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
        if (userInfo[@"email"]) {
            [TikTokBusiness setEmail:userInfo[@"email"]];
        }
        if (userInfo[@"phone"]) {
            [TikTokBusiness setPhoneNumber:userInfo[@"phone"]];
        }
        if (userInfo[@"externalId"]) {
            [TikTokBusiness setExternalId:userInfo[@"externalId"]];
        }
        
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
        [TikTokBusiness setEmail:nil];
        [TikTokBusiness setPhoneNumber:nil];
        [TikTokBusiness setExternalId:nil];
        
        if (self.debugEnabled) {
            NSLog(@"[TikTokEvents] User cleared");
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
    NSString *version = @"1.0.0"; // Plugin version
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
                                                messageAsString:version];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)isInitialized:(CDVInvokedUrlCommand*)command {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
                                                  messageAsBool:self.sdkInitialized];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)setDebug:(CDVInvokedUrlCommand*)command {
    BOOL enabled = [[command.arguments objectAtIndex:0] boolValue];
    self.debugEnabled = enabled;
    
    if (self.sdkInitialized) {
        if (enabled) {
            // Note: Log level can only be set during initialization
            // This is a runtime flag for plugin logging
            NSLog(@"[TikTokEvents] Debug logging enabled");
        }
    }
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
