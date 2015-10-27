//
//  ContentTableViewController.m
//  EnNeMonitor
//
//  Created by Michele Maffei on 13/10/15.
//  Copyright © 2015 Michele Maffei. All rights reserved.
//

#import "ContentTableViewController.h"
#import <MessageUI/MessageUI.h>
#import "ENMBatteryManager.h"
#import "ENMHardwareManager.h"
#import "ENMNetworkInfoManager.h"
#import "ENMNetworkStatisticsManager.h"

@interface ContentTableViewController () <MFMailComposeViewControllerDelegate>
{
    //file handle
    NSFileHandle *fileHandle;
    NSString *logFilePath;
    
    //timers
    NSTimer *masterTimer;
    
    //managers
    ENMBatteryManager *batteryManager;
    ENMHardwareManager *hardwareManager;
    ENMNetworkInfoManager *networkInfoManager;
    ENMNetworkStatisticsManager *networkStatisticsManager;
}

@end

@implementation ContentTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initManagers];
    [self initTable];
    [self initFileHandle];
    [self initFile];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - inits and resets

-(void)initManagers
{
    batteryManager = [[ENMBatteryManager alloc] initWithPowerSource];
    hardwareManager = [[ENMHardwareManager alloc] init];
    networkInfoManager = [[ENMNetworkInfoManager alloc] initWithReachability];
    networkStatisticsManager = [[ENMNetworkStatisticsManager alloc] initWithBuffers];
    
}

-(void)initTimers
{
    masterTimer = [NSTimer scheduledTimerWithTimeInterval:_samplingRate target:self selector:@selector(writeAndUpdateData:) userInfo:nil repeats:YES];
}

-(void)initTable
{
    //model
    
    _ipModel.text = @"N/A";
    _iosLabel.text = @"N/A";
    
    //battery
    
    _percentLabel.text = @"N/A";
    _volLabel.text = @"N/A";
    _ampLabel.text = @"N/A";
    _wattLabel.text = @"N/A";
    _tempLabel.text = @"N/A";
    
    //CPU and Memory
    
    _cpuLabel.text = @"N/A";
    _memLabel.text = @"N/A";
    
    //Network Info
    
    _connLabel.text = @"N/A";
    _wifiLabel.text = @"N/A";
    _gsmLabel.text = @"N/A";
    
    //Network Statistics
    
    _avgWiFius.text = @"N/A";
    _avgWiFids.text = @"N/A";
    _avgWWANus.text = @"N/A";
    _avgWWANds.text = @"N/A";
    _upExWiFi.text = @"N/A";
    _downExWiFi.text = @"N/A";
    _upExWWAN.text = @"N/A";
    _downExWWAN.text = @"N/A";
    
}

-(void)initFileHandle
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docPath = [paths firstObject];
    
    logFilePath = [docPath stringByAppendingPathComponent:@"log.csv"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
        [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:nil attributes:nil];
    }
    
    fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:logFilePath];
}

-(void)initFile
{
    NSString *header = @"Battery %, Battery Voltage (mV), Battery Amperage (mA), Battery Power Output (mW), Battery Temperature (°C), iPhone Model, iOS Version, CPU Load, Memory Usage, Connection Type, WiFi Signal Level (dBm), GSM Signal Level (dBm), Avg WiFi upSpeed, Avg WiFi downSpeed, Avg WWAN upSpeed, Avg WWAN downSpeed, Uplink Exch MB WiFi, Downlink Exch MB WiFi, Uplink Exch MB WWAN, Downlink Exch MB WWAN, Date \n";
    
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[header dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark - write and update data

-(void)writeAndUpdateData:(NSTimer *)timer
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy  HH:mm:ss"];
    
    NSDate *date = [NSDate date];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    NSString *data = [NSString stringWithFormat:@"%@, %@, %@, %@, %@\n", [self getBatteryData], [self getHardwareData], [self getNewtworkInfoData], [self getNetworkStatisticsData], formattedDateString];
    
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark - Battery Data
     
-(NSString *)getBatteryData
{
    double percentage = [batteryManager getPercentage];
    int voltage = [batteryManager getVoltage];
    int amperage = [batteryManager getAmperage];
    int wattage =  [batteryManager getWattage];
    float temperature = [batteryManager getTemperature];
    
    _percentLabel.text = [NSString stringWithFormat:@"%.2f %%", percentage];
    _volLabel.text = [NSString stringWithFormat:@"%i mV", voltage];
    _ampLabel.text = [NSString stringWithFormat:@"%i mA", amperage];
    _wattLabel.text = [NSString stringWithFormat:@"%i mW", wattage];
    _tempLabel.text = [NSString stringWithFormat:@"%.1f °C", temperature];
    
    NSString *batteryData = [NSString stringWithFormat:@"%.2f %%, %i mV, %i mA, %i mW, %.1f °C", percentage, voltage, amperage, wattage, temperature];
    
    return batteryData;
}

#pragma mark - Hardware Data

-(NSString *)getHardwareData
{
    NSString *cpuLoad = [hardwareManager getCPULoad];
    NSString *memoryUsage = [hardwareManager getMemoryUsage];
    NSString *iPhoneModel = [hardwareManager getiPhoneModel];
    NSString *iOSVersion = [hardwareManager getiOSVersion];
    
    _cpuLabel.text = cpuLoad;
    _memLabel.text = memoryUsage;
    _ipModel.text = iPhoneModel;
    _iosLabel.text = iOSVersion;
    
    NSString *hardwareData = [NSString stringWithFormat:@"%@, %@, %@, %@",iPhoneModel, iOSVersion, cpuLoad, memoryUsage];
    
    return hardwareData;
    
}

#pragma mark - Netowrk Info Data

-(NSString *)getNewtworkInfoData
{
    NSString *connectionType = [networkInfoManager getConnectionType];
    int wifidBm = [networkInfoManager getWiFidBm];
    int gsmdBm = [networkInfoManager getGSMdBm];
    
    _connLabel.text = connectionType;
    
    if ([connectionType isEqualToString:@"Not Reachable"]) {
        _wifiLabel.text = @"N/A";
        _gsmLabel.text = @"N/A";
    } else if (![connectionType isEqualToString:@"WiFi"]) {
        _wifiLabel.text = @"N/A";
        _gsmLabel.text = [NSString stringWithFormat:@"%i dBm", gsmdBm];
    } else if (gsmdBm == 0){
        _wifiLabel.text = [NSString stringWithFormat:@"%i dBm", wifidBm];
        _gsmLabel.text = @"N/A";
    } else {
        _wifiLabel.text = [NSString stringWithFormat:@"%i dBm", wifidBm];
        _gsmLabel.text = [NSString stringWithFormat:@"%i dBm", gsmdBm];
    }
    
    NSString *networkInfoData = [NSString stringWithFormat:@"%@, %i dBm, %i dBm", connectionType, wifidBm, gsmdBm];
    
    return networkInfoData;
}

#pragma mark - Network Statistics Data

-(NSString *)getNetworkStatisticsData
{
    NSDictionary *networkStatisticsDic = [[NSDictionary alloc] initWithDictionary:[networkStatisticsManager getNetworkStatistics] copyItems:YES];
    
    float avgWiFius = [[networkStatisticsDic valueForKey:upWiFiSpeedk] floatValue];
    float avgWiFids = [[networkStatisticsDic valueForKey:downWiFiSpeedk] floatValue];
    float avgWWANus = [[networkStatisticsDic valueForKey:upWWANSpeedk] floatValue];
    float avgWWANds = [[networkStatisticsDic valueForKey:downWWANSpeedk] floatValue];
    
    float uMBWiFi = [[networkStatisticsDic valueForKey:upMBExWiFik] floatValue];
    float dMBWiFi = [[networkStatisticsDic valueForKey:downMBExWiFik] floatValue];
    float uMBWWAN = [[networkStatisticsDic valueForKey:upMBExWWANk] floatValue];
    float dMBWWAN = [[networkStatisticsDic valueForKey:downMBExWWANk] floatValue];
    
    _avgWiFius.text = [NSString stringWithFormat:@"%.2f MB", avgWiFius];
    _avgWiFids.text = [NSString stringWithFormat:@"%.2f MB", avgWiFids];
    _avgWWANus.text = [NSString stringWithFormat:@"%.2f MB", avgWWANus];
    _avgWWANds.text = [NSString stringWithFormat:@"%.2f MB", avgWWANds];
    _upExWiFi.text = [NSString stringWithFormat:@"%.2f MB", uMBWiFi];
    _downExWiFi.text = [NSString stringWithFormat:@"%.2f MB", dMBWiFi];
    _upExWWAN.text = [NSString stringWithFormat:@"%.2f MB", uMBWWAN];
    _downExWWAN.text = [NSString stringWithFormat:@"%.2f MB", dMBWWAN];
    
    NSString *networkStatisticsData = [NSString stringWithFormat:@"%.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f", avgWiFius, avgWiFids, avgWWANus, avgWWANds, uMBWiFi, dMBWiFi, uMBWWAN, dMBWWAN];
    
    return networkStatisticsData;
}

#pragma mark - Methods for buttons

-(void)startMonitoring
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
        [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:nil attributes:nil];
        fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:logFilePath];
    }
    
    [networkStatisticsManager startWriting];
    
    [self initTimers];
    [masterTimer fire];
}

-(void)stopMonitoring
{
    [networkStatisticsManager stopWriting];
    
    [self initTable];
    [masterTimer invalidate];
}

-(void)mailLog
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
        NSData *data = [NSData dataWithContentsOfFile:logFilePath];
        if (data == nil) return;
        
        if([MFMailComposeViewController canSendMail] == NO) return;
        
        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
        
        mailVC.mailComposeDelegate = self;
        
        [mailVC addAttachmentData:data mimeType:@"text/csv" fileName:[[logFilePath componentsSeparatedByString:@"/"] lastObject]];
        [mailVC setSubject:@"Energy monitor log"];
        [mailVC setToRecipients: @[@"enne.monitor@gmail.com"]];
        
        [self presentViewController:mailVC animated:YES completion:^{
            
        }];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"No log file in documents directory" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}

-(void)deleteLog
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:logFilePath error:&error];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"No log file in documents directory" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}






















@end
