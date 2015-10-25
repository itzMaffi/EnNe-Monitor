//
//  ENMNetworkStatisticsManager.h
//  EnNeMonitor
//
//  Created by Michele Maffei on 19/10/15.
//  Copyright © 2015 Michele Maffei. All rights reserved.
//

#import <Foundation/Foundation.h>

#define downMBExWiFik  @"downMBExWiFi"
#define upMBExWiFik    @"upMBExWiFi"
#define downMBExWWANk  @"downMBExWWAN"
#define upMBExWWANk    @"upMBExWWAN"
#define downWiFiSpeedk @"downWiFiSpeed"
#define upWiFiSpeedk   @"upWiFiSpeed"
#define downWWANSpeedk @"downWWANSpeed"
#define upWWANSpeedk   @"upWWANSpeed"

@interface ENMNetworkStatisticsManager : NSObject

-(id)initWithBuffers;
-(NSDictionary *)getNetworkStatistics;
-(void)startWriting;
-(void)stopWriting;

@end
