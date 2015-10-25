//
//  ENMNetworkStatisticsManager.m
//  EnNeMonitor
//
//  Created by Michele Maffei on 19/10/15.
//  Copyright © 2015 Michele Maffei. All rights reserved.
//

#import "ENMNetworkStatisticsManager.h"
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>

@implementation ENMNetworkStatisticsManager
{
    NSMutableArray *upSpeedBufferWifi;
    NSMutableArray *downSpeedBufferWifi;
    NSMutableArray *upSpeedBufferWWAN;
    NSMutableArray *downSpeedBufferWWAN;
    
    int iWifiHolder;
    int oWifiHolder;
    int iWWANHolder;
    int oWWANHolder;
    
    int usWifiHolder;
    int dsWifiHolder;
    int usWWANHolder;
    int dsWWANHolder;
    
    NSTimer *speedTimer;
    
    NSTimeInterval timeIntervalHolder;

}

-(id)initWithBuffers
{
    self = [super init];
    
    if (self) {
        upSpeedBufferWifi = nil;
        downSpeedBufferWifi = nil;
        upSpeedBufferWWAN = nil;
        downSpeedBufferWWAN = nil;
    }
    
    return self;
}

- (NSArray *)getDataCounters
{
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    
    int WiFiSent = 0;
    int WiFiReceived = 0;
    int WWANSent = 0;
    int WWANReceived = 0;
    
    NSString *name;
    
    success = getifaddrs(&addrs) == 0;
    
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
            // NSLog(@"ifa_name %s == %@\n", cursor->ifa_name,name);
            // names of interfaces: en0 is WiFi ,pdpXX is WWAN
            
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if ([name hasPrefix:@"en"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WiFiSent+=networkStatisc->ifi_obytes;
                    WiFiReceived+=networkStatisc->ifi_ibytes;
                    //                  NSLog(@"WiFiSent %d ==%d",WiFiSent,networkStatisc->ifi_obytes);
                    //                  NSLog(@"WiFiReceived %d ==%d",WiFiReceived,networkStatisc->ifi_ibytes);
                }
                
                if ([name hasPrefix:@"pdp_ip"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WWANSent+=networkStatisc->ifi_obytes;
                    WWANReceived+=networkStatisc->ifi_ibytes;
                    //                  NSLog(@"WWANSent %d ==%d",WWANSent,networkStatisc->ifi_obytes);
                    //                  NSLog(@"WWANReceived %d ==%d",WWANReceived,networkStatisc->ifi_ibytes);
                }
            }
            
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
    
    NSTimeInterval referenceTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:WiFiReceived], [NSNumber numberWithInt:WiFiSent],[NSNumber numberWithInt:WWANReceived],[NSNumber numberWithInt:WWANSent], [NSNumber numberWithDouble:referenceTimeInterval], nil];;
}

- (NSDictionary *)getNetworkStatistics
{
    NSArray *dataCountersArray = [[NSArray alloc] initWithArray:[self getDataCounters]];
    
    float downWiFiSpeed = [self getAverageSpeedFromBuffer:downSpeedBufferWifi];
    float upWiFiSpeed = [self getAverageSpeedFromBuffer:upSpeedBufferWifi];
    float downWWANSpeed = [self getAverageSpeedFromBuffer:downSpeedBufferWWAN];
    float upWWANSpeed = [self getAverageSpeedFromBuffer:upSpeedBufferWWAN];
    
    float downlinkMBExchangedWiFi = ((((int)dataCountersArray[0] - iWifiHolder) / 1000) / 1000);
    float uplinkMBExchangedWiFi = ((((int)dataCountersArray[1] - oWifiHolder) / 1000) / 1000);
    float downlinkMBExchangedWWAN = ((((int)dataCountersArray[2] - iWWANHolder) / 1000) / 1000);
    float uplinkMBExchangedWWAN = ((((int)dataCountersArray[3] - oWWANHolder) / 1000) / 1000);
    
    
    iWifiHolder = (int)dataCountersArray[0];
    oWifiHolder = (int)dataCountersArray[1];
    iWWANHolder = (int)dataCountersArray[2];
    oWWANHolder = (int)dataCountersArray[3];
    
    downSpeedBufferWifi = nil;
    upSpeedBufferWifi = nil;
    downSpeedBufferWWAN = nil;
    upSpeedBufferWWAN = nil;
    
    NSDictionary *networkStatistics = @{downMBExWiFik : [NSNumber numberWithFloat:downlinkMBExchangedWiFi],
                                        upMBExWiFik   : [NSNumber numberWithFloat:uplinkMBExchangedWiFi],
                                        downMBExWWANk : [NSNumber numberWithFloat:downlinkMBExchangedWWAN],
                                        upMBExWWANk   : [NSNumber numberWithFloat:uplinkMBExchangedWWAN],
                                        downWiFiSpeedk: [NSNumber numberWithFloat:downWiFiSpeed],
                                        upWiFiSpeedk  : [NSNumber numberWithFloat:upWiFiSpeed],
                                        downWWANSpeedk: [NSNumber numberWithFloat:downWWANSpeed],
                                        upWWANSpeedk  : [NSNumber numberWithFloat:upWWANSpeed],
                                        };
                                         
    
    return networkStatistics;
}

- (void)populateSpeedBuffer:(NSTimer *)timer
{
    NSArray *dataCountersArray = [[NSArray alloc] initWithArray:[self getDataCounters]];
    
    if (((int)dataCountersArray[0] - dsWifiHolder) > 1000) {
        float downWiFiSpeed = (((((int)dataCountersArray[0] - dsWifiHolder)/([dataCountersArray[4] doubleValue] - timeIntervalHolder)) / 1000) / 1000);
        if (!downSpeedBufferWifi) {
            downSpeedBufferWifi = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:downWiFiSpeed], nil];
        } else [downSpeedBufferWifi insertObject:[NSNumber numberWithFloat:downWiFiSpeed] atIndex:[downSpeedBufferWifi count]];
    }
    if (((int)dataCountersArray[1] - usWifiHolder) > 1000) {
        float upWiFiSpeed = (((((int)dataCountersArray[1] - usWifiHolder)/([dataCountersArray[4] doubleValue] - timeIntervalHolder)) / 1000) / 100);
        if (!upSpeedBufferWifi) {
            upSpeedBufferWifi  = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:upWiFiSpeed], nil];
        } else [upSpeedBufferWifi insertObject:[NSNumber numberWithFloat:upWiFiSpeed] atIndex:[upSpeedBufferWifi count]];
    }
    if (((int)dataCountersArray[2] - dsWWANHolder) > 1000) {
        float downWWANSpeed = (((((int)dataCountersArray[2] - dsWWANHolder)/([dataCountersArray[4] doubleValue] - timeIntervalHolder)) / 1000) / 1000);
        if (!downSpeedBufferWWAN) {
            downSpeedBufferWWAN  = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:downWWANSpeed], nil];
        } else [downSpeedBufferWWAN insertObject:[NSNumber numberWithFloat:downWWANSpeed] atIndex:[downSpeedBufferWWAN count]];
        
    }
    if (((int)dataCountersArray[3] - usWWANHolder) > 1000) {
        float upWWANSpeed = (((((int)dataCountersArray[3] - usWWANHolder)/([dataCountersArray[4] doubleValue] - timeIntervalHolder)) / 1000) / 1000);
        if (!upSpeedBufferWWAN) {
            upSpeedBufferWWAN  = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:upWWANSpeed], nil];
        } else [upSpeedBufferWWAN insertObject:[NSNumber numberWithFloat:upWWANSpeed] atIndex:[upSpeedBufferWWAN count]];
    }
    
    
    dsWifiHolder = (int)dataCountersArray[0];
    usWifiHolder = (int)dataCountersArray[1];
    dsWWANHolder = (int)dataCountersArray[2];
    usWWANHolder = (int)dataCountersArray[3];
    
    timeIntervalHolder = [dataCountersArray[4] doubleValue];
    
}

- (float)getAverageSpeedFromBuffer:(NSMutableArray *)buffer
{
    float sum = 0;
    
    int idx = 0;
    
    while (idx != [buffer count]) {
        sum += [[buffer objectAtIndex:idx] doubleValue];
        idx++;
    }
    
    if (sum == 0) return  sum;
    return sum / [buffer count];
}

-(void)startWriting
{
    speedTimer = [NSTimer scheduledTimerWithTimeInterval:.25f target:self selector:@selector(populateSpeedBuffer:) userInfo:nil repeats:YES];
    
    NSArray *initialDataArray = [[NSArray alloc] initWithArray:[self getDataCounters] copyItems:YES];
    
    iWifiHolder = (int)initialDataArray[0];
    oWifiHolder = (int)initialDataArray[1];
    iWWANHolder = (int)initialDataArray[2];
    oWWANHolder = (int)initialDataArray[3];
    
    dsWifiHolder = (int)initialDataArray[0];
    usWifiHolder = (int)initialDataArray[1];
    dsWWANHolder = (int)initialDataArray[2];
    usWWANHolder = (int)initialDataArray[3];
    
    
    timeIntervalHolder = [initialDataArray[4] doubleValue];
}

-(void)stopWriting
{
    [speedTimer invalidate];
    
    downSpeedBufferWifi = nil;
    upSpeedBufferWifi = nil;
    downSpeedBufferWWAN = nil;
    upSpeedBufferWWAN = nil;
}

@end
