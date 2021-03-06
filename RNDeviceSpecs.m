//
//  UIDeviceHardware.m
//  PeachMobile
//
//  Created by Eric Sauter on 5/6/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "RNDeviceSpecs.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@import CoreTelephony;

@implementation RNDeviceSpecs

RCT_EXPORT_MODULE()

- (NSString *)platform {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

- (NSString *) carrier {
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    NSString *carrierName = carrier.carrierName;
    if (carrierName == nil) {
        carrierName = @"No Carrier";
    }
    
    return carrierName;
}

- (NSInteger) totalDiskSpace {
    NSNumber *fileSystemSizeInBytes = 0;
    NSInteger fileSystemSizeInGBytes = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        fileSystemSizeInGBytes = [@([fileSystemSizeInBytes floatValue] / 1E+9) integerValue];
    } else {
        NSLog(@"Error Obtaining Disk Memory: Domain = %@, Code = %@", [error domain], [error code]);
    }
    
    return fileSystemSizeInGBytes;
}

- (NSDictionary *)constantsToExport
{
    return @{@"platform": [self platform], @"carrier": [self carrier], @"diskSpace": [NSNumber numberWithInt:[self totalDiskSpace]]};
}



@end
