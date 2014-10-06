//
//  QXAPIManager.m
//  QXCamera
//
//  Created by Hirakawa Akira on 5/10/14.
//  Copyright (c) 2014 Hirakawa Akira. All rights reserved.
//

#import "QXAPIManager.h"
#import "QXAPI.h"
#import "QXLiveManager.h"
#import "UdpRequest.h"
#import "QXXMLParser.h"

@interface QXAPIManager () <QXLiveManagerDelegate>

@property (strong, nonatomic) FetchImageBlock fetchImageBlock;
@property (strong, nonatomic) NSArray *apiList;
@property (strong, nonatomic) QXLiveManager *liveManager;
@property (assign, nonatomic) BOOL isCameraIdle;
@property (assign, nonatomic) BOOL isSupportedVersion;
@end

@implementation QXAPIManager

- (id)init {
    if (self = [super init]) {
        self.liveManager = [[QXLiveManager alloc] init];
        _isCameraIdle = YES;
    }
    return self;
}

- (id)initWithAPI:(QXAPI*)api {
    if (self = [self init]) {
        self.api = api;
    }
    return self;
}

#pragma mark DeviceDiscovery method
- (void)discoveryDevicesWithFetchImageBlock:(FetchImageBlock)block {
    __weak typeof (self) selfie = self;
    [self discoveryDevicesWithDiscoverDeviceBlock:^(NSArray *devices, NSError *error){
        if (devices) {
            QXAPI *api = [[QXAPI alloc] initWithDevice:[devices firstObject]];
            [selfie setApi:api];
            
            BOOL result = [selfie openConnection];
            if (result) {
                [selfie callEventAPI:YES];
                [selfie startLiveViewWithFetchImageBlock:block];
                                
            } else {
                block(nil, [selfie createError:@"couldn't open connection"]);
            }

        } else {
            block(nil, error);
        }
    }];
}

- (void)discoveryDevicesWithDiscoverDeviceBlock:(void (^)(NSArray *, NSError *))block {
    UdpRequest *request = [[UdpRequest alloc] init];
    [request execute:^(NSString *ddUrl, NSArray *uuid) {
        if (ddUrl != nil) {
            QXXMLParser *parser = [[QXXMLParser alloc] init];
            [parser execute:ddUrl block:^(NSArray *devices){
                if (devices != nil && devices.count != 0) {
                    block(devices, nil);
                } else {
                    NSString *errorMessage = @"device not found";
                    NSError *error = [NSError errorWithDomain:@"com.qxcamera" code:35 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
                    block(nil, error);
                }
            }];
        }
        else {
            
            NSString *errorMessage = @"ddUrl not found";
            NSError *error = [NSError errorWithDomain:@"com.qxcamera" code:35 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
            block(nil, error);
        }
    }];
}

#pragma mark OpenConnection methods
- (BOOL)openConnection {
    // get api list
    NSData* response = [_api getAvailableApiList];
    if(response == nil) {
        return NO;
    }
    
    [self parseGetAvailableApiList:response];

    // application info
    if(![self isApiAvailable:APIGetApplicationInfo]){
        return NO;
    }
    
    response = [_api getApplicationInfo];
    if(response == nil) {
        return NO;
    }
    
    [self parseGetApplicationInfo:response];
    
    if(!_isSupportedVersion) {
        return NO;
    }
    return YES;
}

- (BOOL)startLiveViewWithFetchImageBlock:(FetchImageBlock)block {
    self.fetchImageBlock = block;
    
    // start liveview if available
    if(![self isApiAvailable:APIStartLiveview]) {
        return NO;
    }
    
    // finish initialization
    if(![_liveManager isStarted]) {
        NSData *response = [_api startLiveView];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self parseStartLiveView:response];
        });
    }
    
    return YES;
}

#pragma mark Camera methods
- (void)callEventAPI:(BOOL)longPolling {
    [self.api getEvent:(BOOL)longPolling block:^(NSDictionary *json, BOOL isSucceeded) {
        NSArray *array = [json objectForKey:@"result"];
        NSDictionary *dic = [array objectAtIndex:1];
        if(![dic isKindOfClass:[NSNull class]] ) {
            NSString *status = [dic objectForKey:@"cameraStatus"];
            _isCameraIdle = [status isEqualToString:@"IDLE"];
        }
    }];
}

- (void)takePicture:(APIResponseBlock)block {

    if(_isCameraIdle) {
        
        [self.api actTakePictureWithAPIResponseBlock:block];
    }
    else {
        __weak typeof (self) selfie = self;
        [self.api getEvent:(BOOL)NO block:^(NSDictionary *json, BOOL isSucceeded) {
            NSArray *array = [json objectForKey:@"result"];
            NSDictionary *dic = [array objectAtIndex:1];
            NSString *status = [dic objectForKey:@"cameraStatus"];

            selfie.isCameraIdle = [status isEqualToString:@"IDLE"];
            if(selfie.isCameraIdle) {
                [selfie.api actTakePictureWithAPIResponseBlock:block];
            } else {
                block(nil, NO);
            }
        }];
    }
}

- (UIImage *)didTakePicture:(NSDictionary *)json {
    NSArray *array = [json objectForKey:@"result"];
    NSString *endpoint = [[array objectAtIndex:0] objectAtIndex:0];
    
    NSURL *url = [NSURL URLWithString:endpoint];
    NSData *data = [NSData dataWithContentsOfURL:url];

    UIImage *image = nil;
    if(data){
        image = [UIImage imageWithData:data];
    }
    return image;
}

#pragma mark Private methods
- (void)parseStartLiveView:(NSData *)response {
    NSArray *array = [self parseResponse:response];
    NSString* liveviewUrl = array[0];
    NSLog(@"parseStartLiveView liveview = %@",liveviewUrl);
    [_liveManager start:liveviewUrl delegate:self];
}

- (void)parseGetAvailableApiList:(NSData *)response {
    NSArray *array = [self parseResponse:response];
    self.apiList = array[0];
}

- (void)parseGetApplicationInfo:(NSData *)response {
    NSArray *array = [self parseResponse:response];
    if(array.count > 0) {
        NSString *serverName = array[0];
        NSString *serverVersion = array[1];
        NSLog(@"parseGetApplicationInfo serverName = %@", serverName);
        NSLog(@"parseGetApplicationInfo serverVersion = %@", serverVersion);
        if(serverVersion != nil) {
            _isSupportedVersion = [self isSupportedServerVersion:serverVersion];
        }
    }
    
}
- (NSArray*)parseResponse:(NSData *)response {
    
    NSError *e;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:&e];
    NSArray *resultArray = [[NSArray alloc] init];
    NSString* errorMessage = @"";
    NSInteger errorCode = -1;
    if(e) {
        NSLog(@"parseResponse error parsing JSON string");
    }
    else {
        resultArray = dict[@"result"];
        NSArray *errorArray = dict[@"error"];
        if(errorArray!=nil && errorArray.count>0)
        {
            errorCode = (NSInteger)errorArray[0];
            errorMessage = errorArray[1];
        }
    }
    
    return resultArray;
}


- (BOOL)isApiAvailable:(NSString*)apiName {
    if(_apiList != nil && _apiList.count > 0 && [_apiList containsObject:apiName]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isSupportedServerVersion:(NSString*)version {

    NSArray *versionModeList = [version componentsSeparatedByString:@"."];
    if(versionModeList.count > 0) {
        long major = [versionModeList[0] integerValue];
        if(2 <= major) {
            NSLog(@"isSupportedServerVersion YES");
            return YES;
        }
        else {
            NSLog(@"isSupportedServerVersion NO");
        }
    }
    return NO;
}

- (void)debug:(NSData *)response {
    NSString *responseText = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"%@", responseText);
}

-(NSError *)createError:(NSString *)message {
    return [NSError errorWithDomain:@"com.qxcamera" code:35 userInfo:@{NSLocalizedDescriptionKey: message}];
}

#pragma mark QXLiveManagerDelegate methods
- (void)didFetchImage:(UIImage *)image {
    _fetchImageBlock(image, nil);
}

@end
