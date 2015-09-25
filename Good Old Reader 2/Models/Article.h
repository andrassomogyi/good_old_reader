//
//  Article.h
//  Good Old Reader 2
//
//  Created by Somogyi András on 24/09/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Article : NSObject

@property (copy, nonatomic) NSString *articleId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *published;
@property (strong, nonatomic) NSString *canonical;
@property (strong, nonatomic) NSString *summary_content;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSString *origin_streamId;
@property (strong, nonatomic) NSString *origin_title;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;
- (NSString *) shortSummary;

@end
