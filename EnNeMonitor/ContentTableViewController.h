//
//  ContentTableViewController.h
//  EnNeMonitor
//
//  Created by Michele Maffei on 13/10/15.
//  Copyright © 2015 Michele Maffei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UILabel *ipModel;
@property (strong, nonatomic) IBOutlet UILabel *percentLabel;
@property (strong, nonatomic) IBOutlet UILabel *volLabel;
@property (strong, nonatomic) IBOutlet UILabel *ampLabel;
@property (strong, nonatomic) IBOutlet UILabel *wattLabel;
@property (strong, nonatomic) IBOutlet UILabel *tempLabel;
@property (strong, nonatomic) IBOutlet UILabel *cpuLabel;
@property (strong, nonatomic) IBOutlet UILabel *memLabel;
@property (strong, nonatomic) IBOutlet UILabel *connLabel;
@property (strong, nonatomic) IBOutlet UILabel *wifiLabel;
@property (strong, nonatomic) IBOutlet UILabel *gsmLabel;
@property (strong, nonatomic) IBOutlet UILabel *avgWiFius;
@property (strong, nonatomic) IBOutlet UILabel *avgWiFids;
@property (strong, nonatomic) IBOutlet UILabel *avgWWANus;
@property (strong, nonatomic) IBOutlet UILabel *avgWWANds;
@property (strong, nonatomic) IBOutlet UILabel *upExWiFi;
@property (strong, nonatomic) IBOutlet UILabel *downExWiFi;
@property (strong, nonatomic) IBOutlet UILabel *upExWWAN;
@property (strong, nonatomic) IBOutlet UILabel *downExWWAN;

@property (nonatomic) float samplingRate;

-(void)startMonitoring;
-(void)stopMonitoring;

@end
