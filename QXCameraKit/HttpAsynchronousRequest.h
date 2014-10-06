//
//  HttpAsynchronousRequest.h
//  QXCamera
//
//  Created by Hirakawa Akira on 5/10/14.
//  Copyright (c) 2014 Hirakawa Akira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QXAPI.h"

@protocol HttpAsynchronousRequestParserDelegate <NSObject>

- (void)parseMessage:(NSData*)response apiName:(NSString*)apiName;
@end

@interface HttpAsynchronousRequest : NSObject

- (void)call:(NSString*)url postParams:(NSString*)params apiName:(NSString*)apiName delegate:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate;
- (void)call:(NSString*)url postParams:(NSString*)params apiName:(NSString*)apiName block:(APIResponseBlock)block;
@end
