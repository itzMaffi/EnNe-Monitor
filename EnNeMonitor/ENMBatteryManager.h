//
//  ENMBatteryManager.h
//  EnNeMonitor
//
//  Created by Michele Maffei on 13/10/15.
//  Copyright © 2015 Michele Maffei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/ps/IOPowerSources.h>
#import <IOKit/ps/IOPSKeys.h>
#import <IOKit/pwr_mgt/IOPM.h>
#import <IOKit/IOKitLib.h>

@interface ENMBatteryManager : NSObject

-(id)initWithPowerSource;
-(int)getVoltage;
-(int)getAmperage;
-(int)getWattage;
-(double)getPercentage;
-(float)getTemperature;

@end
