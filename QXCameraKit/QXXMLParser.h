//
//  QXXMLParser.h
//  QXCamera
//
//  Created by Hirakawa Akira on 5/10/14.
//  Copyright (c) 2014 Hirakawa Akira. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ParserCompletionBlock)(NSArray* devices);

@interface QXXMLParser : NSObject<NSXMLParserDelegate>

- (void)execute:(NSString *)url block:(ParserCompletionBlock)block;
@end
