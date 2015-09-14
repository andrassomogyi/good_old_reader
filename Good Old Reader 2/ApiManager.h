//
//  ApiManager.h
//  Good Old Reader 2
//
//  Created by András Somogyi on 14/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApiManager : NSObject

+ (void)queryApiUrl:(NSURL *)url withCompletion:(void(^)(NSData * data))completion withError:(void(^)(NSError *error, NSInteger statusCode))errorBlock;

@end
