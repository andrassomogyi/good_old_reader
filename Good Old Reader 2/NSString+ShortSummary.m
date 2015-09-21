//
//  NSString+ShortSummary.m
//  Good Old Reader 2
//
//  Created by Somogyi András on 21/09/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "NSString+ShortSummary.h"

@implementation NSString (ShortSummary)

+ (NSString *)shortSummaryFromString:(NSString *)string summaryLength:(NSInteger)length {
    string = [self stripTags:string]; // Stripping HTML tags
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; // Stripping unnecessary whitespace characters
    string = [self truncate:string to:length]; // Shortening if possible
    return string;
}

+ (NSString *)truncate:(NSString *)string to:(NSInteger)words {
    NSArray *summaryWordsArray = [string componentsSeparatedByString:@" "];
    if (summaryWordsArray.count >= words) {
        NSRange summaryRange = NSMakeRange(0, words);
        summaryWordsArray = [summaryWordsArray subarrayWithRange:summaryRange];
        return [[summaryWordsArray componentsJoinedByString:@" "] stringByAppendingString:@"..."];
    } else {
        return string;
    }
}

+ (NSString *)stripTags:(NSString *)stringToStrip {
    NSMutableString *html = [NSMutableString stringWithCapacity:[stringToStrip length]];
    NSScanner *scanner = [NSScanner scannerWithString:stringToStrip];
    scanner.charactersToBeSkipped = nil;
    NSString *tempString = nil;
    while (![scanner isAtEnd]) {
        [scanner scanUpToString:@"<" intoString:&tempString];
        if (tempString != nil)
            [html appendString:tempString];
        [scanner scanUpToString:@">" intoString:nil];
        if (![scanner isAtEnd])
            [scanner setScanLocation:[scanner scanLocation] + 1];
        tempString = nil;
    }
    return html;
}

@end
