//
//  QXAPI.h
//  QXCamera
//
//  Created by Hirakawa Akira on 5/10/14.
//  Copyright (c) 2014 Hirakawa Akira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QXDevice.h"

////////////// API list
static NSString* APIGetAvailableApiList = @"getAvailableApiList";
static NSString* APIGetApplicationInfo = @"getApplicationInfo";
static NSString* APIGetEvent = @"getEvent";

//shoot api
static NSString* APIGetShootMode = @"getShootMode";
static NSString* APISetShootMode = @"setShootMode";
static NSString* APIGetAvailableShootMode = @"getAvailableShootMode";
static NSString* APIGetSupportedShootMode = @"getSupportedShootMode";

//liveview api
static NSString* APIStartLiveview = @"startLiveview";
static NSString* APIStopLiveview = @"stopLiveview";
static NSString* APIActTakePicture = @"actTakePicture";
static NSString* APIActZoom = @"actZoom";

//shutter api
static NSString *APIActHalfPressShutter = @"actHalfPressShutter";
static NSString *APICancelHalfPressShutter = @"cancelHalfPressShutter";

//af position api
static NSString *APISetTouchAfPosition = @"setTouchAFPosition";
static NSString *APIGetTouchAfPosition = @"getTouchAFPosition";
static NSString *APICancelTouchAfPosition = @"cancelTouchAFPosition";

//postview api
static NSString *APIGetPostviewImageSize= @"getPostviewImageSize";
static NSString *APISetPostviewImageSize= @"setPostviewImageSize";
static NSString *APIGetSupportedPostviewImageSize= @"getSupportedPostviewImageSize";
static NSString *APIGetAvailablePostviewImageSize= @"getAvailablePostviewImageSize";
//////////////

@protocol QXAPIDelegate <NSObject>

- (void)didReceiveAPIResponse:(NSString *)api json:(NSDictionary *)json;
- (void)didReceiveAPIErrorResponse:(NSString *)api json:(NSDictionary *)json;
@end

typedef void (^APIResponseBlock)(NSDictionary *json, BOOL isSucceeded);

@interface QXAPI : NSObject

- (id)initWithDevice:(QXDevice *)device;

- (NSData *)getAvailableApiList;
- (NSData *)getApplicationInfo;
- (NSData *)startLiveView;

- (void)getEvent:(BOOL)longPolling block:(APIResponseBlock)block;

// Zoom methods
- (void)startZoomInWithAPIResponseBlock:(APIResponseBlock)block;
- (void)stopZoomInWithAPIResponseBlock:(APIResponseBlock)block;
- (void)startZoomOutWithAPIResponseBlock:(APIResponseBlock)block;
- (void)stopZoomOutWithAPIResponseBlock:(APIResponseBlock)block;

//postview methods
- (void)getSupportedPostviewImageSizeWithAPIResponseBlock:(APIResponseBlock)block;
- (void)getAvailableImageSizeWithAPIResponseBlock:(APIResponseBlock)block;
- (void)getPostviewImageSizeWithAPIResponseBlock:(APIResponseBlock)block;
- (void)setPostviewImageSize:(NSString *)size block:(APIResponseBlock)block;

// Picture methods
- (void)actTakePictureWithAPIResponseBlock:(APIResponseBlock)block;

// TouchAFPosition methods
- (void)setTouchAFPosition:(int)x y:(int)y block:(APIResponseBlock)block;
- (void)getTouchAFPosition:(int)x y:(int)y block:(APIResponseBlock)block;
- (void)cancelTouchAFPosition:(int)x y:(int)y block:(APIResponseBlock)block;

@end
