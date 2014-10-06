//
//  QXDevice.h
//  QXCamera
//
//  Created by Hirakawa Akira on 5/10/14.
//  Copyright (c) 2014 Hirakawa Akira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QXDevice : NSObject

@property (copy, nonatomic) NSString *friendlyName;
@property (copy, nonatomic) NSString *version;
@property (strong, nonatomic) NSMutableArray* serviceNameArray;
@property (strong, nonatomic) NSMutableArray* serviceURLArray;

- (void)addService:(NSString*)serviceName url:(NSString*)serviceUrl;
- (NSString*)findActionListUrl:(NSString*)service;

@end
