//
//  ENMBatteryManager.m
//  EnNeMonitor
//
//  Created by Michele Maffei on 13/10/15.
//  Copyright © 2015 Michele Maffei. All rights reserved.
//

#import "ENMBatteryManager.h"

@implementation ENMBatteryManager

{
    io_service_t powerSource;
    int voltage;
    int amperage;
    int wattage;
    double percentage;
    float temperature;
}

-(id)initWithPowerSource
{
    self = [super init];
    
    if (self) {
        powerSource = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPMPowerSource"));
    }
    
    return self;
}

-(int)getVoltage
{
    voltage = -1;
    
    if (powerSource) {
        CFNumberRef voltageNum = (CFNumberRef)IORegistryEntryCreateCFProperty(powerSource, CFSTR("Voltage"), kCFAllocatorDefault, 0);
        CFNumberGetValue(voltageNum, kCFNumberIntType, &voltage);
        CFRelease(voltageNum);
    }
    
    return voltage;
}

-(int)getAmperage
{
    amperage = -1;
    
    if (powerSource) {
        CFNumberRef amperageNum = (CFNumberRef)IORegistryEntryCreateCFProperty(powerSource, CFSTR("InstantAmperage"), kCFAllocatorDefault, 0);
        CFNumberGetValue(amperageNum, kCFNumberIntType, &amperage);
        CFRelease(amperageNum);
    }
    
    return amperage;
}

-(int)getWattage
{
    wattage = abs((voltage*amperage)/1000);
    
    return wattage;
}

-(double)getPercentage
{
    percentage = -1;
    
    int currentCapacity;
    int maxCapacity;
    
    if (powerSource) {
        CFNumberRef currentCapacityNum = (CFNumberRef)IORegistryEntryCreateCFProperty(powerSource, CFSTR("CurrentCapacity"), kCFAllocatorDefault, 0);
        CFNumberGetValue(currentCapacityNum, kCFNumberIntType, &currentCapacity);
        CFRelease(currentCapacityNum);
        
        CFNumberRef maxCapacityNum = (CFNumberRef)IORegistryEntryCreateCFProperty(powerSource, CFSTR("MaxCapacity"), kCFAllocatorDefault, 0);
        CFNumberGetValue(maxCapacityNum, kCFNumberIntType, &maxCapacity);
        CFRelease(maxCapacityNum);
    }
    
    percentage = (double)currentCapacity/(double)maxCapacity * 100.0f;
    
    return percentage;
}

-(float)getTemperature
{
    temperature = -1;
    
    if (powerSource) {
        CFNumberRef temperatureNum = (CFNumberRef)IORegistryEntryCreateCFProperty(powerSource, CFSTR("Temperature"), kCFAllocatorDefault, 0);
        CFNumberGetValue(temperatureNum, kCFNumberFloatType, &temperature);
        CFRelease(temperatureNum);
    }
    
    return temperature/100.0f;
}



@end
