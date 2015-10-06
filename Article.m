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
    managedArticle.origin_streamId = article.origin_streamId;
    managedArticle.origin_title = article.origin_title;
    managedArticle.published = article.published;
    managedArticle.summary_content = article.summary_content;
    managedArticle.title = article.title;
    
    return managedArticle;
}

+ (NSString*)entityName {
    return @"Article";
}

@end
