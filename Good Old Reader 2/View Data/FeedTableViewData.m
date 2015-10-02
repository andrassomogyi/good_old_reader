//
//  FeedTableViewData.m
//  Good Old Reader 2
//
//  Created by József Vesza on 02/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "FeedTableViewData.h"

@interface FeedTableViewData ()

@property (nonatomic, copy, readwrite) NSArray *articleArray;
@property (nonatomic, copy, readwrite) NSString *title;

@end

@implementation FeedTableViewData

- (instancetype)initWithArticles:(NSArray *)articles title:(NSString *)title
{
    self = [super init];
    if (self) {
        self.articleArray = articles;
        self.title = title;
    }
    return self;
}

@end
