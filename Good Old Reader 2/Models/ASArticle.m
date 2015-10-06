//
//  ASArticle.m
//  Good Old Reader 2
//
//  Created by Somogyi András on 24/09/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "ASArticle.h"
#import "NSString+ShortSummary.h"

@implementation ASArticle

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.articleId = dictionary[@"articleId"];
        self.title = dictionary[@"title"];
        self.published = dictionary[@"published"];
        self.canonical = dictionary[@"canonical"];
        self.summary_content = dictionary[@"summary_content"];
        self.author = dictionary[@"author"];
        self.origin_streamId = dictionary[@"origin_streamId"];
        self.origin_title = dictionary[@"origin_title"];
    }
    return self;
}

- (NSString *)shortSummary {
    return [NSString shortSummaryFromString:self.summary_content summaryLength:25];
}

- (NSString *)datePublished {
    NSDate *articleUpdateDate = [NSDate dateWithTimeIntervalSince1970:[self.published doubleValue]];
    NSDateFormatter *articleUpdateDateFormatter = [[NSDateFormatter alloc] init];
    [articleUpdateDateFormatter setDateStyle:NSDateFormatterShortStyle];
    [articleUpdateDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [articleUpdateDateFormatter stringFromDate:articleUpdateDate];
}

@end
