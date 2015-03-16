//
//  Http.h
//  Good Old Reader
//
//  Created by András Somogyi on 2014. 11. 26..
//  Copyright (c) 2014. András Somogyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Http : NSObject
@property NSMutableData *receivedData;
@property NSString *networkError;
@property BOOL dataReady;
- (id) initWithUrlPost:(NSString*)url postData:(NSString*)post;
- (id) initWithUrlGet:(NSString*)url;
@end
