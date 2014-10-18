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
//server information
static NSString* APIGetAvailableApiList = @"getAvailableApiList";
static NSString* APIGetApplicationInfo = @"getApplicationInfo";
static NSString* APIGetEvent = @"getEvent";
static NSString* APIGetVersions = @"getVersions";
static NSString* APIGetMethodTypes = @"getMethodTypes";

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

//exposure mode api
static NSString *APISetExposureMode = @"setExposureMode";
static NSString *APIGetExposureMode = @"getExposureMode";
static NSString *APIGetSupportedExposureMode = @"getSupportedExposureMode";
static NSString *APIGetAvailableExposureMode = @"getAvailableExposureMode";

//iso spped rate api
static NSString *APISetIsoSpeedRate = @"setIsoSpeedRate";
static NSString *APIGetIsoSpeedRate = @"getIsoSpeedRate";
static NSString *APIGetSupportedIsoSpeedRate = @"getSupportedIsoSpeedRate";
static NSString *APIGetAvailableIsoSpeedRate = @"getAvailableIsoSpeedRate";

//white balance api
static NSString *APISetWhiteBalance = @"setWhiteBalance";
static NSString *APIGetWhiteBalance = @"getWhiteBalance";
static NSString *APIGetSupportedWhiteBalance = @"getSupportedWhiteBalance";
static NSString *APIGetAvailableWhiteBalance = @"getAvailableWhiteBalance";

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

// Server Information
- (NSData *)getAvailableApiList;
- (NSData *)getApplicationInfo;
- (void)getVersions:(APIResponseBlock)block;
- (void)getMethodTypes:(NSString *)version block:(APIResponseBlock)block;
- (void)getEvent:(BOOL)longPolling block:(APIResponseBlock)block;
- (NSData *)startLiveView;

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

// Half-Press Shutter methods
- (void)actHalfPressShutterWithAPIResponseBlock:(APIResponseBlock)block;
- (void)cancelHalfPressShutterWithAPIResponseBlock:(APIResponseBlock)block;

// ExposureMode methods
- (void)setExposureMode:(NSString *)mode block:(APIResponseBlock)block;
- (void)getExposureModeWithAPIResponseBlock:(APIResponseBlock)block;
- (void)getSupportedExposureModeWithAPIResponseBlock:(APIResponseBlock)block;
- (void)getAvailableExposureModeWithAPIResponseBlock:(APIResponseBlock)block;

// ISO Speed rate methods
- (void)setIsoSpeedRate:(NSString *)rate block:(APIResponseBlock)block;
- (void)getIsoSpeedRateWithAPIResponseBlock:(APIResponseBlock)block;
- (void)getSupportedIsoSpeedRateWithAPIResponseBlock:(APIResponseBlock)block;
- (void)getAvailableIsoSpeedRateWithAPIResponseBlock:(APIResponseBlock)block;

// White Balance methods
- (void)setWhiteBalance:(NSString *)balance block:(APIResponseBlock)block;
- (void)getWhiteBalanceWithAPIResponseBlock:(APIResponseBlock)block;
- (void)getSupportedWhiteBalanceWithAPIResponseBlock:(APIResponseBlock)block;
- (void)getAvailableWhiteBalanceWithAPIResponseBlock:(APIResponseBlock)block;

// TouchAFPosition methods
- (void)setTouchAFPosition:(double)x y:(double)y block:(APIResponseBlock)block;
- (void)getTouchAFPositionWithAPIResponseBlock:(APIResponseBlock)block;
- (void)cancelTouchAFPositionWithAPIResponseBlock:(APIResponseBlock)block;

@end
