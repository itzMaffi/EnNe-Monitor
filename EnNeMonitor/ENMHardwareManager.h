//
//  ENMHardwareManager.h
//  EnNeMonitor
//
//  Created by Michele Maffei on 14/10/15.
//  Copyright © 2015 Michele Maffei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ENMHardwareManager : NSObject

-(NSString *)getMemoryUsage;
-(NSString *)getCPULoad;
-(NSString *)getiPhoneModel;
-(NSString *)getiOSVersion;

@end
