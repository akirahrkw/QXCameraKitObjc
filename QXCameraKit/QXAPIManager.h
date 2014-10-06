//
//  QXAPIManager.h
//  QXCamera
//
//  Created by Hirakawa Akira on 5/10/14.
//  Copyright (c) 2014 Hirakawa Akira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#import "QXAPI.h"

typedef void (^FetchImageBlock)(UIImage *image, NSError *error);

@interface QXAPIManager : NSObject

@property (strong, nonatomic) QXAPI *api;

- (id)initWithAPI:(QXAPI*)api;

- (void)discoveryDevicesWithFetchImageBlock:(FetchImageBlock)block;
- (void)discoveryDevicesWithDiscoverDeviceBlock:(void (^)(NSArray *, NSError *))block;

//take picture
- (void)takePicture:(APIResponseBlock)block;
- (UIImage *)didTakePicture:(NSDictionary *)json;
//- (BOOL)openConnectionWithFetchImageBlock:(FetchImageBlock)block;

@end
