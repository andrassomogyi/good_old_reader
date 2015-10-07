//
//  ASArticle.h
//  Good Old Reader 2
//
//  Created by Somogyi András on 24/09/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASArticle : NSObject

@property (strong, nonatomic) NSString *articleId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSNumber *published;
@property (strong, nonatomic) NSString *canonical;
@property (strong, nonatomic) NSString *summaryContent;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSString *originStreamId;
@property (strong, nonatomic) NSString *originTitle;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)shortSummary;
- (NSString *)datePublished;

@end
