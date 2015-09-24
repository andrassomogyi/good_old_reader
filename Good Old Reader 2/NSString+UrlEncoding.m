//
//  NSString+UrlEncoding.m
//  Good Old Reader 2
//
//  Created by András Somogyi on 17/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import "NSString+UrlEncoding.h"

@implementation NSString (UrlEncoding)

+ (NSString *)encodeUrl:(NSDictionary *)dictionary {
        NSMutableArray *parts = [[NSMutableArray alloc] init];
    
        for (id key in dictionary) {
            id value = dictionary[key];
    
            NSString *encodedKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSString *encodedValue = [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
            NSString *part = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
            [parts addObject:part];
        }
        return [parts componentsJoinedByString:@"&"];
}

@end
