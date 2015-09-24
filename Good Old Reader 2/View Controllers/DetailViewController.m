//
//  DetailViewController.m
//  Good Old Reader 2
//
//  Created by András Somogyi on 2015. 02. 04..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@end

@implementation DetailViewController
#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self displayArticle];
}
#pragma mark - Actions
- (void)displayArticle {
    NSString *articleUpdateDateString = @"";
    NSString *articleTitle = @"No title";
    NSString *articleAuthor = @"Anonymus";
    NSString *articleOrigin = @"No site";
    NSString *articleSummary = @"";
    
    // Query article title if exists
    if (self.articleContainer.title.length > 0) {
        articleTitle = self.articleContainer.title;
    }
    
    // Query article author if exists
    if (self.articleContainer.author.length > 0) {
        articleAuthor = self.articleContainer.author;
    }
    
    // Query article update date if exists
    if (self.articleContainer.published) {
        NSDate *articleUpdateDate = [NSDate dateWithTimeIntervalSince1970:[self.articleContainer.published doubleValue]];
        NSDateFormatter *articleUpdateDateFormatter = [[NSDateFormatter alloc] init];
        [articleUpdateDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [articleUpdateDateFormatter setTimeStyle:NSDateFormatterShortStyle];
        articleUpdateDateString = [articleUpdateDateFormatter stringFromDate:articleUpdateDate];
    }
    
    // Query origin site if exists
    if (self.articleContainer.origin_title.length > 0) {
        articleOrigin = self.articleContainer.origin_title;
    }
    
    // Query article text if exists
    if (self.articleContainer.summary_content.length > 0) {
        articleSummary = self.articleContainer.summary_content;
    }
    
    NSMutableString *preparedArticle = [NSMutableString stringWithString:@"<style type='text/css'>img { max-width: 100%; width: auto; height: auto;}body{font-family:helvetica; font-size:12px;}</style>"];
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
    
    [self.articleDisplay loadHTMLString:preparedArticle baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

