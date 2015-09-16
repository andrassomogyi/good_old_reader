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
/// URL for count of unread articles
extern NSString * const UNREAD_COUNT_URL;
/// URL for mark article read
extern NSString * const MARK_AS_READ_URL;
/// URL for obtaining token
extern NSString * const GET_TOKEN_URL;
/// URL for client login
extern NSString * const CLIENT_LOGIN_URL;
/// URL for client logout
extern NSString * const CLIENT_LOGOUT_URL;


///
/// An enum representing endpoints.
///
typedef NS_ENUM(NSInteger, Endpoint)
{
    UnreadEndpoint,
    UnreadCountEndpoint,
    MarkAsReadEndpoint,
    GetTokenEndpoint,
    ClientLoginEndpoint,
    ClientLogoutEndpoint
};

@interface EndpointResolver : NSObject

/// Return the corresponding URL for a given endpoint.
///
/// @param endpoint The requested endpoint.
///
/// @return The resolved URL.
+ (NSURL *)URLForEndpoint:(Endpoint)endpoint;

@end