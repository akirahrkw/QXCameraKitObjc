//
//  UdpRequest.h
//  QXCamera
//
//  Created by Hirakawa Akira on 5/10/14.
//  Copyright (c) 2014 Hirakawa Akira. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionBlock)(NSString *ddUrl, NSArray *uuid);

@interface UdpRequest : NSObject

- (void)execute:(CompletionBlock)block;
- (void)stop;
@end
