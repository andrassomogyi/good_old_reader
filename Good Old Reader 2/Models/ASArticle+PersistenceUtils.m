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
    
    article.articleId = managedArticle.articleId;
    article.author = managedArticle.author;
    article.canonical = managedArticle.canonical;
    article.originStreamId = managedArticle.originStreamId;
    article.originTitle = managedArticle.originTitle;
    article.published = managedArticle.published;
    article.summaryContent = managedArticle.summaryContent;
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
