//
//  DetailViewController.m
//  Good Old Reader 2
//
//  Created by András Somogyi on 2015. 02. 04..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//

#import "DetailViewController.h"
#import "ApiManager.h"
#import "Article+HTMLRepresentation.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *articleDisplay;
@end

@implementation DetailViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self displayArticle];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self markAsReadOnServer];
}

#pragma mark - Actions
- (void)displayArticle {
    [self.articleDisplay loadHTMLString:[Article HTMLRepresentation:self.articleContainer] baseURL:nil];
}

- (void)markAsReadOnServer {
    // Mart article read on server
    [ApiManager markArticleRead:self.articleContainer.articleId withCompletion:nil withError:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
