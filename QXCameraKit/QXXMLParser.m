//
//  QXXMLParser.m
//  QXCamera
//
//  Created by Hirakawa Akira on 5/10/14.
//  Copyright (c) 2014 Hirakawa Akira. All rights reserved.
//

#import "QXXMLParser.h"
#import "QXDevice.h"

@interface QXXMLParser ()

@property (strong, nonatomic) QXDevice *device;
@property (strong, nonatomic) NSXMLParser *parser;
@property (strong, nonatomic) NSMutableArray *devices;
@property (copy, nonatomic) NSString* currentServiceName;
@property (assign, nonatomic) int parseStatus; // 0->friendlyName, 1->version, 2-> ServiceType, 3-> ActionList URL
@property (assign, nonatomic) BOOL isParsingService;
@property (assign, nonatomic) BOOL isCameraDevice;
@property (strong, nonatomic) ParserCompletionBlock block;

@end

@implementation QXXMLParser

- (id)init {
    if (self = [super init]) {
        self.devices = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)execute:(NSString *)url block:(ParserCompletionBlock)block {
    self.block = block;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData* xmlFile = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    _parseStatus = -1;
    self.parser = [[NSXMLParser alloc] initWithData:xmlFile];
    [_parser setDelegate:self];
    [_parser setShouldProcessNamespaces:NO];
    [_parser setShouldReportNamespacePrefixes:NO];
    [_parser setShouldResolveExternalEntities:NO];
    [_parser parse];
}

#pragma mark NSXMLParserDelegate methods
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"XML File found and parsing started");
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSString *errorString = [NSString stringWithFormat:@"Error code %li", (long)[parseError code]];
    NSLog(@"Error: parsing XML: %@", errorString);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"device"]) {
        self.device = [[QXDevice alloc] init];
        _isCameraDevice = NO;
    }
    else if ([elementName isEqualToString:@"friendlyName"]) {
        _parseStatus = 0;
    }
    else if ([elementName isEqualToString:@"av:X_ScalarWebAPI_Version"]) {
        _parseStatus = 1;
    }
    else if ([elementName isEqualToString:@"av:X_ScalarWebAPI_Service"]) {
        _isParsingService = YES;
    }
    else if ([elementName isEqualToString:@"av:X_ScalarWebAPI_ServiceType"]) {
        _parseStatus = 2;
    }
    else if ([elementName isEqualToString:@"av:X_ScalarWebAPI_ActionList_URL"]) {
        _parseStatus = 3;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if(_parseStatus == 0) {
        [_device setFriendlyName:string];
    }
    else if(_parseStatus == 1) {
        [_device setVersion:string];
    }
    else if(_parseStatus == 2 && _isParsingService) {
        _currentServiceName = [string copy];
        if([@"camera" isEqualToString:_currentServiceName]) {
            _isCameraDevice = YES;
        }
    }
    else if(_parseStatus == 3 && _isParsingService) {
        [_device addService:_currentServiceName url:[string copy]];
        _currentServiceName = nil;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"device"]) {
        if(_isCameraDevice) {
            [_devices addObject:_device];
        }
        _isCameraDevice = NO;
    }
    else if ([elementName isEqualToString:@"friendlyName"]) {
        _parseStatus = -1;
    }
    else if ([elementName isEqualToString:@"av:X_ScalarWebAPI_Version"]) {
        _parseStatus = -1;
    }
    else if ([elementName isEqualToString:@"av:X_ScalarWebAPI_Service"]) {
        _isParsingService = NO;
    }
    else if ([elementName isEqualToString:@"av:X_ScalarWebAPI_ServiceType"]) {
        _parseStatus = -1;
    }
    else if ([elementName isEqualToString:@"av:X_ScalarWebAPI_ActionList_URL"]) {
        _parseStatus = -1;
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    _block(_devices);
}

@end
