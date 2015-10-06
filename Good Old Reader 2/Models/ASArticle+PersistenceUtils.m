//
//  ASArticle+PersistenceUtils.m
//  Good Old Reader 2
//
//  Created by József Vesza on 06/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "ASArticle+PersistenceUtils.h"
#import "Article.h"

@implementation ASArticle (PersistenceUtils)

+ (instancetype)modelRepresentation:(Article *)managedArticle {
    
    ASArticle *article = [[ASArticle alloc] init];
    
    article.author = managedArticle.author;
    article.canonical = managedArticle.canonical;
    article.origin_streamId = managedArticle.origin_streamId;
    article.origin_title = managedArticle.origin_title;
    article.published = managedArticle.published;
    article.summary_content = managedArticle.summary_content;
    article.title = managedArticle.title;
    
    return article;
}

+ (NSArray *)modelRepresentationForItems:(NSArray *)items {

    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (Article *article in items) {
        [array addObject:[self modelRepresentation:article]];
    }
    
    return array;
}

@end
