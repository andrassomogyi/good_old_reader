//
//  EndpointResolver.h
//  Good Old Reader 2
//
//  Created by Vesza József on 14/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Base URL, used in every url.
extern NSString * const BASE_URL;
/// URL for the unread endpoint.
extern NSString * const UNREAD_URL;

///
/// An enum representing endpoints.
///
typedef NS_ENUM(NSInteger, Endpoint)
{
    UnreadEndpoint,
};

@interface EndpointResolver : NSObject

/// Return the corresponding URL for a given endpoint.
///
/// @param endpoint The requested endpoint.
///
/// @return The resolved URL.
+ (NSURL *)URLForEndpoint:(Endpoint)endpoint;

@end