//
//  QXAPI.m
//  QXCamera
//
//  Created by Hirakawa Akira on 5/10/14.
//  Copyright (c) 2014 Hirakawa Akira. All rights reserved.
//

#import "QXAPI.h"
#import "HttpAsynchronousRequest.h"

@interface QXAPI () <HttpAsynchronousRequestParserDelegate>

@property (assign, nonatomic) int qxid;
@property (strong, nonatomic) QXDevice* device;
@property (weak, nonatomic) id<QXAPIDelegate> delegate;
@end

@implementation QXAPI

- (id)initWithDevice:(QXDevice *)device {
    if (self = [super init]) {
        _qxid = 1;
        self.device = device;
    }
    return self;
}

#pragma mark ServerInformation methods
- (NSData *)getAvailableApiList {
    NSString *url = [_device findActionListUrl:@"camera"];
    NSString *requestJson = [self createRequestJson:APIGetAvailableApiList];
    return [self call:url postParams:requestJson];
}

- (NSData *)getApplicationInfo {
    NSString *url = [_device findActionListUrl:@"camera"];
    NSString *requestJson = [self createRequestJson:APIGetApplicationInfo];
    return [self call:url postParams:requestJson];
}

- (void)getVersions:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetVersions params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetVersions params:requestJson block:block];
}

- (void)getMethodTypes:(NSString *)version block:(APIResponseBlock)block {
    NSString *params = [NSString stringWithFormat:@"[\"%@\"]", version];
    NSString *requestJson = [self createRequestJson:APIGetMethodTypes params:params];
    [self createCameraAsynchronousRequest:APIGetMethodTypes params:requestJson block:block];
}

- (void)getEvent:(BOOL)longPolling block:(APIResponseBlock)block {
    NSString *param = longPolling ? @"true" : @"false";
    NSString *params = [NSString stringWithFormat:@"[%@]", param];
    NSString *requestJson = [self createRequestJson:APIGetEvent params:params];
    [self createCameraAsynchronousRequest:APIGetEvent params:requestJson block:block];
}

#pragma mark Zoom methods
- (void)startZoomInWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *params = [NSString stringWithFormat:@"[\"%@\",\"%@\"]", @"in" ,@"start"];
    NSString *requestJson = [self createRequestJson:APIActZoom params:params];
    [self createCameraAsynchronousRequest:APIActZoom params:requestJson block:block];
}

- (void)stopZoomInWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *params = [NSString stringWithFormat:@"[\"%@\",\"%@\"]", @"in" ,@"stop"];
    NSString *requestJson = [self createRequestJson:APIActZoom params:params];
    [self createCameraAsynchronousRequest:APIActZoom params:requestJson block:block];
}

- (void)startZoomOutWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *params = [NSString stringWithFormat:@"[\"%@\",\"%@\"]", @"out" ,@"start"];
    NSString *requestJson = [self createRequestJson:APIActZoom params:params];
    [self createCameraAsynchronousRequest:APIActZoom params:requestJson block:block];
}

- (void)stopZoomOutWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *params = [NSString stringWithFormat:@"[\"%@\",\"%@\"]", @"out" ,@"stop"];
    NSString *requestJson = [self createRequestJson:APIActZoom params:params];
    [self createCameraAsynchronousRequest:APIActZoom params:requestJson block:block];
}

#pragma mark StillSize methods
- (void)getSupportedStillSizeWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetSupportedStillSize params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetSupportedStillSize params:requestJson block:block];
}

- (void)getAvailableStillSizeWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetAvailableStillSize params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetAvailableStillSize params:requestJson block:block];
}

- (void)getStillSizeWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetStillSize params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetStillSize params:requestJson block:block];
}
- (void)setStillSize:(NSString *)aspect size:(NSString *)size block:(APIResponseBlock)block {
    NSString *params = [NSString stringWithFormat:@"[\"%@\",\"%@\"]", aspect ,size];
    NSString *requestJson = [self createRequestJson:APISetStillSize params:params];
    [self createCameraAsynchronousRequest:APISetStillSize params:requestJson block:block];
}

#pragma mark PostView methods
- (void)getSupportedPostviewImageSizeWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetSupportedPostviewImageSize params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetSupportedPostviewImageSize params:requestJson block:block];
}

- (void)getAvailableImageSizeWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetAvailablePostviewImageSize params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetAvailablePostviewImageSize params:requestJson block:block];
}

- (void)getPostviewImageSizeWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetPostviewImageSize params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetPostviewImageSize params:requestJson block:block];
}

- (void)setPostviewImageSize:(NSString *)size block:(APIResponseBlock)block {
    NSString *params = [NSString stringWithFormat:@"[\"%@\"]", size];
    NSString *requestJson = [self createRequestJson:APISetPostviewImageSize params:params];
    [self createCameraAsynchronousRequest:APISetPostviewImageSize params:requestJson block:block];
}

#pragma mark StillCapture methods
- (void)actTakePictureWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIActTakePicture params:@"[]"];
    [self createCameraAsynchronousRequest:APIActTakePicture params:requestJson block:block];
}

#pragma mark HalfPress methods
- (void)actHalfPressShutterWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIActHalfPressShutter params:@"[]"];
    [self createCameraAsynchronousRequest:APIActHalfPressShutter params:requestJson block:block];
}
- (void)cancelHalfPressShutterWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APICancelHalfPressShutter params:@"[]"];
    [self createCameraAsynchronousRequest:APICancelHalfPressShutter params:requestJson block:block];
}

#pragma mark TouchAF methods
- (void)setTouchAFPosition:(double)x y:(double)y block:(APIResponseBlock)block {
    NSString *params = [NSString stringWithFormat:@"[%f, %f]", x , y];
    NSString *requestJson = [self createRequestJson:APISetTouchAfPosition params:params];
    [self createCameraAsynchronousRequest:APISetTouchAfPosition params:requestJson block:block];
}

- (void)getTouchAFPositionWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetTouchAfPosition params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetTouchAfPosition params:requestJson block:block];
}

- (void)cancelTouchAFPositionWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APICancelTouchAfPosition params:@"[]"];
    [self createCameraAsynchronousRequest:APICancelTouchAfPosition params:requestJson block:block];
}

#pragma mark ExposureMode methods
- (void)setExposureMode:(NSString *)mode block:(APIResponseBlock)block {
    NSString *params = [NSString stringWithFormat:@"[\"%@\"]", mode];
    NSString *requestJson = [self createRequestJson:APISetExposureMode params:params];
    [self createCameraAsynchronousRequest:APISetExposureMode params:requestJson block:block];
}

- (void)getExposureModeWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetExposureMode params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetExposureMode params:requestJson block:block];
}

- (void)getSupportedExposureModeWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetSupportedExposureMode params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetSupportedExposureMode params:requestJson block:block];
}

- (void)getAvailableExposureModeWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetAvailableExposureMode params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetAvailableExposureMode params:requestJson block:block];
}

#pragma mark IsoSpeedRate methods
- (void)setIsoSpeedRate:(NSString *)rate block:(APIResponseBlock)block {
    NSString *params = [NSString stringWithFormat:@"[\"%@\"]", rate];
    NSString *requestJson = [self createRequestJson:APISetIsoSpeedRate params:params];
    [self createCameraAsynchronousRequest:APISetIsoSpeedRate params:requestJson block:block];
}

- (void)getIsoSpeedRateWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetIsoSpeedRate params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetIsoSpeedRate params:requestJson block:block];
}

- (void)getSupportedIsoSpeedRateWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetSupportedIsoSpeedRate params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetSupportedIsoSpeedRate params:requestJson block:block];
}

- (void)getAvailableIsoSpeedRateWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetAvailableIsoSpeedRate params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetAvailableIsoSpeedRate params:requestJson block:block];
}

#pragma mark WhiteBalance methods
- (void)setWhiteBalance:(NSString *)balance block:(APIResponseBlock)block {
    NSString *params = [NSString stringWithFormat:@"[\"%@\"]", balance];
    NSString *requestJson = [self createRequestJson:APISetWhiteBalance params:params];
    [self createCameraAsynchronousRequest:APISetWhiteBalance params:requestJson block:block];
}

- (void)getWhiteBalanceWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetWhiteBalance params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetWhiteBalance params:requestJson block:block];
}

- (void)getSupportedWhiteBalanceWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetSupportedWhiteBalance params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetSupportedWhiteBalance params:requestJson block:block];
}

- (void)getAvailableWhiteBalanceWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetAvailableWhiteBalance params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetAvailableWhiteBalance params:requestJson block:block];
}

#pragma mark Shoot methods
- (void)setShootMode:(NSString *)mode {
    NSString *params = [NSString stringWithFormat:@"[\"%@\"]", mode];
    NSString *requestJson = [self createRequestJson:APISetShootMode params:params];
    [self createCameraAsynchronousRequest:APISetShootMode params:requestJson];
}

- (void)getShootMode {
    NSString *requestJson = [self createRequestJson:APIGetShootMode];
    [self createCameraAsynchronousRequest:APIGetShootMode params:requestJson];
}

- (void)getSupportedShootMode {
    NSString *requestJson = [self createRequestJson:APIGetSupportedShootMode params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetSupportedShootMode params:requestJson];
}

- (void)getAvailableShootMode {
    NSString *requestJson = [self createRequestJson:APIGetAvailableShootMode params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetAvailableShootMode params:requestJson];
}

#pragma mark LiveView methods
- (NSData *)startLiveView {
    NSString *url = [_device findActionListUrl:@"camera"];
    NSString *requestJson = [self createRequestJson:APIStartLiveview];
    return [self call:url postParams:requestJson];
}

- (void)stopLiveView {
    NSString *requestJson = [self createRequestJson:APIStopLiveview params:@"[]"];
    [self createCameraAsynchronousRequest:APIStopLiveview params:requestJson];
}

#pragma mark BeepMode methods
- (void)getBeepModeWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetBeepMode params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetBeepMode params:requestJson block:block];
}

- (void)setBeepMode:(NSString *)mode block:(APIResponseBlock)block {
    NSString *params = [NSString stringWithFormat:@"[\"%@\"]", mode];
    NSString *requestJson = [self createRequestJson:APISetBeepMode params:params];
    [self createCameraAsynchronousRequest:APISetBeepMode params:requestJson block:block];
}
- (void)getSupportedBeepModeWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetSupportedBeepMode params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetSupportedBeepMode params:requestJson block:block];
}
- (void)getAvailableBeepModeWithAPIResponseBlock:(APIResponseBlock)block {
    NSString *requestJson = [self createRequestJson:APIGetAvailableBeepMode params:@"[]"];
    [self createCameraAsynchronousRequest:APIGetAvailableBeepMode params:requestJson block:block];
}

#pragma mark Private methods
- (int)getId {
    return _qxid++;
}

- (void)createCameraAsynchronousRequest:(NSString *)api params:(NSString *)json block:(APIResponseBlock)block{
    NSString *url = [_device findActionListUrl:@"camera"];
    HttpAsynchronousRequest *request = [[HttpAsynchronousRequest alloc] init];
    [request call:url postParams:json apiName:api block:block];
}

- (void)createCameraAsynchronousRequest:(NSString *)api params:(NSString *)json {
    NSString *url = [_device findActionListUrl:@"camera"];
    HttpAsynchronousRequest *request = [[HttpAsynchronousRequest alloc] init];
    [request call:url postParams:json apiName:api delegate:self];
}

- (NSString *)createRequestJson:(NSString *)method {
    return [self createRequestJson:method params:@"[]"];
}

- (NSString *)createRequestJson:(NSString *)method params:(NSString *)params{
    NSString *version = @"1.0";
    NSString *requestJson = [NSString stringWithFormat:@"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }", method, params, version,[self getId]];
    return requestJson;
}

- (NSData*)call:(NSString*)url postParams:(NSString*)params
{
    NSLog(@"API Request url:%@ params:%@", url, params);
    
    NSURL *aUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    NSString *postString = params;
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    return data;
}

#pragma mark HttpAsynchronousRequestParserDelegate methods
- (void)parseMessage:(NSData*)response apiName:(NSString*)apiName {
    NSError *e;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:&e];
    
    id error =[dict objectForKey:@"error"];
    if (error) {
        [self.delegate didReceiveAPIResponse:apiName json:dict];
    } else {
        [self.delegate didReceiveAPIErrorResponse:apiName json:dict];
    }
}
@end
