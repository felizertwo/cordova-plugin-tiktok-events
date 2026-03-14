//
//  TikTokEventsPlugin.h
//  TikTok Events SDK - Cordova Plugin
//
//  Created by ADS4U Digital
//

#import <Cordova/CDV.h>

@interface TikTokEventsPlugin : CDVPlugin

// Initialization
- (void)initialize:(CDVInvokedUrlCommand*)command;
- (void)requestTrackingAuthorization:(CDVInvokedUrlCommand*)command;

// Event Tracking
- (void)trackEvent:(CDVInvokedUrlCommand*)command;

// User Identity
- (void)identifyUser:(CDVInvokedUrlCommand*)command;
- (void)clearUser:(CDVInvokedUrlCommand*)command;

// Utility
- (void)getVersion:(CDVInvokedUrlCommand*)command;
- (void)isInitialized:(CDVInvokedUrlCommand*)command;
- (void)setDebug:(CDVInvokedUrlCommand*)command;

@end
