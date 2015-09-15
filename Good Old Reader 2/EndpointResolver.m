//
//  EndpointResolver.m
//  Good Old Reader 2
//
//  Created by Vesza József on 14/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import "EndpointResolver.h"

NSString * const BASE_URL = @"https://theoldreader.com/";
NSString * const UNREAD_URL = @"reader/atom/user/-/state/com.google/reading-list?xt=user/-/state/com.google/read&output=json&n=1000";
NSString * const UNREAD_COUNT_URL = @"reader/api/0/unread-count?output=json";
NSString * const MARK_AS_READ_URL = @"reader/api/0/edit-tag";
NSString * const GET_TOKEN_URL = @"reader/api/0/token?output=json";
NSString * const CLIENT_LOGIN_URL = @"accounts/ClientLogin";

@implementation EndpointResolver

+ (NSURL *)URLForEndpoint:(Endpoint)endpoint {
    
    //1. Create url according to the requested endpoint.
    NSString *endpointString;
    switch (endpoint) {
        case 0:
            endpointString = UNREAD_URL;
            break;

        case 1:
            endpointString = UNREAD_COUNT_URL;
            break;
            
        case 2:
            endpointString = MARK_AS_READ_URL;
            break;

        case 3:
            endpointString = GET_TOKEN_URL;
            break;
            
        case 4:
            endpointString = CLIENT_LOGIN_URL;
            break;

        default:
            break;
    }
    
    
    //2. Assemble full url.
    NSURL *fullUrl = [NSURL URLWithString:[BASE_URL stringByAppendingString:endpointString]];
    
    return fullUrl;
}

@end