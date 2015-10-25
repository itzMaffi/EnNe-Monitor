//
//  ENMNetworkInfoManager.h
//  EnNeMonitor
//
//  Created by Michele Maffei on 14/10/15.
//  Copyright © 2015 Michele Maffei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ENMNetworkInfoManager : NSObject

-(id)initWithReachability;
-(NSString *)getConnectionType;
-(int)getWiFidBm;
-(int)getGSMdBm;


@end
