//
//  QXDevice.m
//  QXCamera
//
//  Created by Hirakawa Akira on 5/10/14.
//  Copyright (c) 2014 Hirakawa Akira. All rights reserved.
//

#import "QXDevice.h"

@implementation QXDevice

- (id)init {
    if (self = [super init]) {
        self.serviceNameArray = [[NSMutableArray alloc] init];
        self.serviceURLArray = [[NSMutableArray alloc] init];
    }
    return self;
}

// adds service to the list
- (void)addService:(NSString*)serviceName url:(NSString*)serviceUrl {
    [_serviceNameArray addObject:serviceName];
    [_serviceURLArray addObject:[serviceUrl stringByAppendingFormat:@"/%@",serviceName]];
    NSLog(@"DeviceInfo addService = %@:%@", serviceName, serviceUrl);
    NSLog(@"DeviceInfo _serviceNameArray size = %lu", (unsigned long)_serviceNameArray.count);
}

// finds the ActionListURL for a given service
- (NSString*)findActionListUrl:(NSString*)service {
    long index = [_serviceNameArray indexOfObject:service];
    if(index >= 0) {
        return _serviceURLArray[index];
    }
    return @"Not found";
}

@end
