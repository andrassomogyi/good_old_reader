//
//  FeedTableViewData.h
//  Good Old Reader 2
//
//  Created by József Vesza on 02/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedTableViewData : NSObject

@property (nonatomic, copy, readonly) NSArray *articleArray;
@property (nonatomic, copy, readonly) NSString* title;

- (instancetype)initWithArticles:(NSArray *)articles title:(NSString *)title;

@end
