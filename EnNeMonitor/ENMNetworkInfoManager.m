//
//  ENMNetworkInfoManager.m
//  EnNeMonitor
//
//  Created by Michele Maffei on 14/10/15.
//  Copyright © 2015 Michele Maffei. All rights reserved.
//

#import "ENMNetworkInfoManager.h"
#import <UIKit/UIKit.h>
#import "Reachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <MobileWiFi/MobileWiFi.h>

@implementation ENMNetworkInfoManager
{
    Reachability *internetReachable;
}

-(id)initWithReachability
{
    self = [super init];
    
    if (self) {
        internetReachable = [Reachability reachabilityWithHostName:@"www.google.it"];
    }
    
    return self;
}

-(NSString *)getConnectionType
{
    NSString *connectionType;
    
    if ([internetReachable isReachableViaWWAN]) {
        
        CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        NSString *currentRadio = networkInfo.currentRadioAccessTechnology;
        
        if ([currentRadio isEqualToString:CTRadioAccessTechnologyLTE]) {
            connectionType = @"LTE";
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyHSDPA] || [currentRadio isEqualToString:CTRadioAccessTechnologyHSUPA]){
            connectionType = @"HSPA";
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyWCDMA]) {
            connectionType = @"3G";
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyGPRS]) {
            connectionType = @"GPRS";
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyEdge]) {
            connectionType = @"EDGE";
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyCDMA1x] || [currentRadio isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] || [currentRadio isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] || [currentRadio isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
            connectionType = @"CDMA";
        }
        
    } else if ([internetReachable isReachableViaWiFi]) {
        connectionType = @"WiFi";
    } else connectionType = @"Not Reachable";

    
    return connectionType;
}

-(int)getGSMdBm
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSString *dataNetworkItemView = nil;
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarSignalStrengthItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    
    int gsmSignalStrength = [[dataNetworkItemView valueForKey:@"signalStrengthRaw"] intValue];
    
    return gsmSignalStrength;
}

-(int)getWiFidBm
{
    WiFiManagerRef manager = WiFiManagerClientCreate(kCFAllocatorDefault, 0);
    CFArrayRef devices = WiFiManagerClientCopyDevices(manager);
    
    WiFiDeviceClientRef client = (WiFiDeviceClientRef)CFArrayGetValueAtIndex(devices, 0);
    CFDictionaryRef data = (CFDictionaryRef)WiFiDeviceClientCopyProperty(client, CFSTR("RSSI"));
    
    CFNumberRef RSSI = (CFNumberRef)CFDictionaryGetValue(data, CFSTR("RSSI_CTL_AGR"));
    
    int raw;
    CFNumberGetValue(RSSI, kCFNumberIntType, &raw);
    
    CFRelease(data);
    CFRelease(devices);
    CFRelease(manager);
    
    return raw;
}


@end
