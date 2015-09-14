//
//  EndpointResolver.m
//  Good Old Reader 2
//
//  Created by Vesza József on 14/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import "EndpointResolver.h"

NSString * const BASE_URL = @"https://theoldreader.com/reader/api";
NSString * const UNREAD_URL = @"api/0/unread-count?output=json";

@implementation EndpointResolver

+ (NSURL *)URLForEndpoint:(Endpoint)endpoint {
    
    //1. Create url according to the requested endpoint.
    NSString *endpointString = nil;
    
    //2. Assemble full url.
    NSURL *fullUrl = nil;
    
    return fullUrl;
}

@end