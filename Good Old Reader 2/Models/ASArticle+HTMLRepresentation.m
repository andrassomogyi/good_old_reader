//
//  Article+HTMLRepresentation.m
//  Good Old Reader 2
//
//  Created by Somogyi András on 25/09/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "ASArticle+HTMLRepresentation.h"

@implementation ASArticle (HTMLRepresentation)

+ (NSString *) HTMLRepresentation:(ASArticle *)article {
    
    NSString *articleUpdateDateString = @"";
    NSString *articleTitle = @"No title";
    NSString *articleAuthor = @"Anonymus";
    NSString *articleOrigin = @"No site";
    NSString *articleSummary = @"";
    
    // Query article title if exists
    if (article.title.length > 0) {
        articleTitle = article.title;
    }
    
    // Query article author if exists
    if (article.author.length > 0) {
        articleAuthor = article.author;
    }
    
    // Query article update date if exists
    if (article.published) {
        articleUpdateDateString = [article datePublished];
    }
    
    // Query origin site if exists
    if (article.originTitle.length > 0) {
        articleOrigin = article.originTitle;
    }
    
    // Query article text if exists
    if (article.summaryContent.length > 0) {
        articleSummary = article.summaryContent;
    }
    
    NSMutableString *preparedArticle = [NSMutableString stringWithString:@"<style type='text/css'>img { max-width: 100%; width: auto; height: auto;}body{font-family:helvetica; font-size:16px;}</style>"];
    [preparedArticle appendString:@"<h1>"];
    [preparedArticle appendString:articleTitle];
    [preparedArticle appendString:@"</h1>"];
    [preparedArticle appendString:@"<p><i>"];
    [preparedArticle appendString:articleAuthor];
    [preparedArticle appendString:@", "];
    [preparedArticle appendString:articleOrigin];
    [preparedArticle appendString:@", "];
    [preparedArticle appendString:articleUpdateDateString];
    [preparedArticle appendString:@"</i></p>"];
    [preparedArticle appendString:articleSummary];

    return preparedArticle;
}

@end
