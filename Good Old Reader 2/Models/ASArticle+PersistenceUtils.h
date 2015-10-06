//
//  ASArticle+PersistenceUtils.h
//  Good Old Reader 2
//
//  Created by József Vesza on 06/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "ASArticle.h"
@class Article;

@interface ASArticle (PersistenceUtils)

+ (instancetype)modelRepresentation:(Article *)managedArticle;
+ (NSArray *)modelRepresentationForItems:(NSArray *)items;

@end
