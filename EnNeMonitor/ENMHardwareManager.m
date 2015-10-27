//
//  ENMHardwareManager.m
//  EnNeMonitor
//
//  Created by Michele Maffei on 14/10/15.
//  Copyright © 2015 Michele Maffei. All rights reserved.
//

#import "ENMHardwareManager.h"
#import <mach/mach.h> //for CPU and Memory
#import <sys/sysctl.h>  //for iPhone Model

@implementation ENMHardwareManager

#pragma mark - Memory

- (float)totalMemory
{
    double totalMemory = 0.00;
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return -1;
    }
    totalMemory = ((vm_page_size * (vmStats.active_count + vmStats.inactive_count + vmStats.wire_count + vmStats.free_count)) / 1024) / 1024;
    
    return totalMemory;
}

- (float)freeMemory
{
    double freeMemory = 0.00;
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return -1;
    }
    freeMemory = ((vm_page_size * vmStats.free_count) / 1024) / 1024;
    
    return freeMemory;
}

- (float)usedMemory
{
    double usedMemory = 0.00;
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return -1;
    }
    usedMemory = ((vm_page_size * (vmStats.active_count + vmStats.inactive_count + vmStats.wire_count)) / 1024) / 1024;
    
    return usedMemory;
}

- (float)activeMemory
{
    double activeMemory = 0.00;
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return -1;
    }
    activeMemory = ((vm_page_size * vmStats.active_count) / 1024) / 1024;
    
    return activeMemory;
}

- (float)wiredMemory
{
    double wiredMemory = 0.00;
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return -1;
    }
    wiredMemory = ((vm_page_size * vmStats.wire_count) / 1024) / 1024;
    
    return wiredMemory;
}

- (float)inactiveMemory
{
    double inactiveMemory = 0.00;
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return -1;
    }
    inactiveMemory = ((vm_page_size * vmStats.inactive_count) / 1024) / 1024;
    
    return inactiveMemory;
}

- (NSString *)getMemoryUsage
{
    
    float freeMemoryPercent = ([self freeMemory] * 100)/[self totalMemory];
    float activeMemoryPercent = (([self usedMemory] - [self wiredMemory] - [self inactiveMemory]) * 100)/[self totalMemory];
    float wiredMemoryPercent = ([self wiredMemory] * 100)/[self totalMemory];
    float inactiveMemoryPercent = ([self inactiveMemory] * 100)/[self totalMemory];
    
    NSString *memoryUsage = [NSString stringWithFormat:@"F:%.2f - A:%.2f - W:%.2f - I:%.2f", freeMemoryPercent, activeMemoryPercent, wiredMemoryPercent, inactiveMemoryPercent];
    
    return memoryUsage;
}

#pragma mark - CPU

- (float)cpu_usage
{
    kern_return_t			kr = { 0 };
    task_info_data_t		tinfo = { 0 };
    mach_msg_type_number_t	task_info_count = TASK_INFO_MAX;
    
    kr = task_info( mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count );
    if ( KERN_SUCCESS != kr )
        return 0.0f;
    
    task_basic_info_t		basic_info = { 0 };
    thread_array_t			thread_list = { 0 };
    mach_msg_type_number_t	thread_count = { 0 };
    
    thread_info_data_t		thinfo = { 0 };
    thread_basic_info_t		basic_info_th = { 0 };
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads( mach_task_self(), &thread_list, &thread_count );
    if ( KERN_SUCCESS != kr )
        return 0.0f;
    
    long	tot_sec = 0;
    long	tot_usec = 0;
    float	tot_cpu = 0;
    
    for ( int i = 0; i < thread_count; i++ )
    {
        mach_msg_type_number_t thread_info_count = THREAD_INFO_MAX;
        
        kr = thread_info( thread_list[i], THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count );
        if ( KERN_SUCCESS != kr )
            return 0.0f;
        
        basic_info_th = (thread_basic_info_t)thinfo;
        if ( 0 == (basic_info_th->flags & TH_FLAGS_IDLE) )
        {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE *100;
        }
    }
    
    kr = vm_deallocate( mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t) );
    if ( KERN_SUCCESS != kr )
        return 0.0f;
    
    return tot_cpu;
}

- (NSString *)getCPULoad
{
    NSString *cpuLoad = [NSString stringWithFormat:@"%.2f %%", [self cpu_usage]];
    
    return cpuLoad;
}

#pragma mark - iPhone Model

-(NSString *)getPlatform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    
    free(machine);
    
    return platform;
}

- (NSString *)getiPhoneModel
{
    NSString *platform = [self getPlatform];
    
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (China)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3 (2013)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

-(NSString *)getiOSVersion
{
    NSString *iOSVersion = [[NSProcessInfo processInfo] operatingSystemVersionString];
    
    return iOSVersion;
}


@end
