//
//  Article.m
//  Good Old Reader 2
//
//  Created by Somogyi András on 06/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "Article.h"

@implementation Article

+ (instancetype)insertArticle:(ASArticle *)article inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    Article* managedArticle = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:managedObjectContext];
    managedArticle.author = article.author;
    managedArticle.canonical = article.canonical;
    managedArticle.originStreamId = article.originStreamId;
    managedArticle.originTitle = article.originTitle;
    managedArticle.published = article.published;
    managedArticle.summaryContent = article.summaryContent;
    managedArticle.title = article.title;
    managedArticle.articleId = article.articleId;
    
    return managedArticle;
}

+ (NSString*)entityName {
    return @"Article";
}

@end
