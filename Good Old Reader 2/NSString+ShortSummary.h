//
//  NSString+ShortSummary.h
//  Good Old Reader 2
//
//  Created by Somogyi András on 21/09/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (ShortSummary)

+ (NSString *)shortSummaryFromString:(NSString *)string summaryLength:(NSInteger)length;

+ (NSString *)truncate:(NSString *)string to:(NSInteger)words;

+ (NSString *)stripTags:(NSString *)stringToStrip;

@end
