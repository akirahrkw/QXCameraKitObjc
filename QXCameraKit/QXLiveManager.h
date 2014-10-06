//
//  QXLiveManager.h
//  QXCamera
//
//  Created by Hirakawa Akira on 5/10/14.
//  Copyright (c) 2014 Hirakawa Akira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>

@protocol QXLiveManagerDelegate <NSObject>

- (void)didFetchImage:(UIImage *)image;
@end

@interface QXLiveManager : NSObject

@property (assign, nonatomic) BOOL isStarted;

- (void)start:(NSString *)liveviewUrl delegate:(id<QXLiveManagerDelegate>)delegate;
@end
