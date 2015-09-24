//
//  NSString+UrlEncoding.h
//  Good Old Reader 2
//
//  Created by András Somogyi on 17/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UrlEncoding)

+ (NSString *)encodeUrl:(NSDictionary *)dictionary;

@end
