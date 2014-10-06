//
//  HttpAsynchronousRequest.m
//  QXCamera
//
//  Created by Hirakawa Akira on 5/10/14.
//  Copyright (c) 2014 Hirakawa Akira. All rights reserved.
//

#import "HttpAsynchronousRequest.h"

@interface HttpAsynchronousRequest ()

@property (weak, nonatomic) id<HttpAsynchronousRequestParserDelegate> delegate;
@property (copy, nonatomic) NSString *apiName;
@property (strong, nonatomic) NSMutableData *receiveData;
@property (strong, nonatomic) APIResponseBlock block;
@end

@implementation HttpAsynchronousRequest

- (void)call:(NSString*)url postParams:(NSString*)params apiName:(NSString*)apiName block:(APIResponseBlock)block {
    self.block = block;
    self.apiName = apiName;
    self.receiveData = [NSMutableData data];
    NSURL *aUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection= [[NSURLConnection alloc] initWithRequest:request
                                                                 delegate:self
                                                         startImmediately:NO];
    [connection start];
}

- (void) call:(NSString*)url postParams:(NSString*)params apiName:(NSString*)apiName delegate:(id<HttpAsynchronousRequestParserDelegate>)delegate
{
    self.delegate = delegate;
    self.apiName = apiName;
    self.receiveData = [NSMutableData data];
    NSURL *aUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];

    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection= [[NSURLConnection alloc] initWithRequest:request
                                                                 delegate:self
                                                         startImmediately:NO];
    [connection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_receiveData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receiveData appendData:data];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"HttpRequest didFailWithError = %@", error);
    NSString* errorResponse =@"{ \"id\"= 0 , \"error\"=[16,\"Transport Error\"]}";
    
    if(_delegate) {
        [_delegate parseMessage:[errorResponse dataUsingEncoding:NSUTF8StringEncoding] apiName:_apiName];
    } else {        
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[errorResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:NSJSONReadingMutableContainers error:&e];
        
        _block(dict, false);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (_delegate) {
        [_delegate parseMessage:_receiveData apiName:_apiName];
    } else {
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:_receiveData
                                                             options:NSJSONReadingMutableContainers error:&e];
        
        _block(dict, true);
    }
}

@end
