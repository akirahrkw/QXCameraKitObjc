//
//  QXLiveManager.m
//  QXCamera
//
//  Created by Hirakawa Akira on 5/10/14.
//  Copyright (c) 2014 Hirakawa Akira. All rights reserved.
//

#import "QXLiveManager.h"

@interface QXLiveManager ()

@property (strong, nonatomic) NSMutableData *receiveData;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSURLConnection *connection;
@property (copy, nonatomic) NSString *liveviewUrl;
@property (weak, nonatomic) id<QXLiveManagerDelegate> delegate;
@end

@implementation QXLiveManager

- (void)start:(NSString *)liveviewUrl delegate:(id<QXLiveManagerDelegate>)delegate {
    if(!_isStarted){
        _isStarted = YES;
        self.liveviewUrl = liveviewUrl;
        self.receiveData = [[NSMutableData alloc] init];
        self.url = [NSURL URLWithString:_liveviewUrl];
        self.delegate = delegate;
        [self readStream:_url];
    }
}

- (void)readStream:(NSURL *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"GET"];
    self.connection= [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    [_connection start];
}

#pragma mark NSURLConnection methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    @synchronized(self) {
        [_receiveData setLength:0];
    }
    [self performSelectorInBackground:@selector(getPackets) withObject:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    @synchronized(self) {
        [_receiveData appendData:data];
    }
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
}

/*
 * Start getting JPEG packets
 */
-(void) getPackets {
    while(true && _isStarted) {
        @autoreleasepool {
            [self getJPEGPacket];
        }
    }
}

/*
 * Get a single JPEG packet
 */
-(void) getJPEGPacket
{
    uint8_t b[8];
    // remove first 8 bytes from stream
    [self readBytes:8 buffer:b];
    
    // read for JPEG image
    [self getPayload];
}

/*
 * Get payload data of JPEG image
 */
-(void) getPayload
{
    NSInteger jpegDataSize = 0;
    NSInteger jpegPaddingSize = 0;
    
    // check for first 4 bytes
    [self readBytes:-1 buffer:nil];
    
    // get JPEG data size
    uint8_t jData[3];
    [self readBytes:3 buffer:jData];
    jpegDataSize = [self bytesToInt:jData count:3];
    
    // get JPEG padding size
    uint8_t jPad[1];
    [self readBytes:1 buffer:jPad];
    jpegPaddingSize = [self bytesToInt:jPad count:1];
    
    // remove 120 bytes from stream
    uint8_t b1[120];
    [self readBytes:120 buffer:b1];
    
    // read JPEG image
    uint8_t jpegData[jpegDataSize];
    [self readBytes:jpegDataSize buffer:jpegData];
    
    NSData *imageData = [[NSData alloc] initWithBytes:jpegData length:jpegDataSize];
    
    UIImage *tempImage = [UIImage imageWithData:imageData];
    if([self isJPEGValid:imageData]) {
        [_delegate didFetchImage:tempImage];
    }
    
    // remove JPEG padding data
    uint8_t padData[jpegPaddingSize];
    [self readBytes:jpegPaddingSize buffer:padData];
}

/*
 * check JPEG validity
 */
- (BOOL)isJPEGValid:(NSData *)data
{
    if (!data || data.length < 2) return NO;
    
    const char *bytes = (const char*)[data bytes];
    return (bytes[0] == (char)0xff &&
            bytes[1] == (char)0xd8);
}

/*
 * Read bytes from _receiveData
 */
-(void) readBytes:(NSInteger) length  buffer:(uint8_t*)buffer
{
    // check for payload first 4 bytes
    if(length==-1)
    {
        while(true && _isStarted)
        {
            BOOL isValid = YES;
            @synchronized(self)
            {
                if(_receiveData!=NULL && _receiveData.length < 4) {
                    isValid = NO;
                }
            }
            if(isValid) {
                break;
            }
            else
            {
                sleep(0.01);
            }
        }
        uint8_t checkByte[4];
        checkByte[0] = 0x24;
        checkByte[1] = 0x35;
        checkByte[2] = 0x68;
        checkByte[3] = 0x79;
        
        NSData *checkData = [NSData dataWithBytes:checkByte length:4];
        BOOL isFound = NO;
        
        NSRange found = NSMakeRange(0, 4);
        
        @synchronized(self)
        {
            if(_isStarted) {
                found = [_receiveData rangeOfData:checkData options:NSDataSearchAnchored range:found];
            }
        }
        
        if(found.location!=NSNotFound && _isStarted)
        {
            @synchronized(self)
            {
                // remove extra bytes from the beginning
                [_receiveData replaceBytesInRange:NSMakeRange(0, 4) withBytes:NULL length:0];
            }
            return;
        }
        
        // In case the data is corrupted and first 4 bytes are not checkBytes, this loop will find the checkBytes.
        // NOTE : not used in general cases
        while (!isFound && _isStarted)
        {
            long maxRangeLength = 0;
            @synchronized(self)
            {
                maxRangeLength = _receiveData.length;
            }
            NSRange currentRange = NSMakeRange(0, maxRangeLength);
            
            @synchronized(self)
            {
                found = [_receiveData rangeOfData:checkData options:NSDataSearchBackwards range:currentRange];
            }
            if(found.location!=NSNotFound)
            {
                NSRange lastFound = found;
                
                // search if there is checkBytes before the lastFound
                //while (found.location!=NSNotFound && found.location > 4 && _isStarted)
                //{
                //    maxRangeLength = found.location-1;
                //    lastFound = found;
                //    currentRange = NSMakeRange(0, maxRangeLength);
                //    @synchronized(self)
                //    {
                //        found = [_receiveData rangeOfData:checkData options:NSDataSearchBackwards range:currentRange];
                //    }
                //}
                isFound = YES; // found latest checkBytes
                @synchronized(self)
                {
                    // remove extra bytes from the beginning
                    [_receiveData replaceBytesInRange:NSMakeRange(0, lastFound.location+4) withBytes:NULL length:0];
                }
            }
            else
            {
                // wait for getting enough bytes
                sleep(0.1);
            }
        }
        return;
    }
    else {
        
        // remove specified length from _receiveData
        while(true && _isStarted)
        {
            BOOL isValid = NO;
            @synchronized(self)
            {
                if(_receiveData!=NULL && _receiveData.length > length) {
                    isValid = YES;
                }
            }
            if(isValid) {
                break;
            }
            else
            {
                // wait for making enough buffer
                sleep(0.5);
            }
        }
        
        
        // ASSERT : length is sufficient
        @synchronized(self)
        {
            if(_receiveData != NULL && _isStarted)
            {
                [_receiveData getBytes:buffer length:length];
                [_receiveData replaceBytesInRange:NSMakeRange(0, length) withBytes:NULL length:0];
            }
        }
    }
}

-(NSInteger) bytesToInt:(uint8_t*)bytes count:(NSInteger)count
{
    NSInteger val = 0;
    for(int i=0; i<count; i++)
    {
        val = (val << 8) | (bytes[i] & 0xff);
    }
    return val;
}

@end
