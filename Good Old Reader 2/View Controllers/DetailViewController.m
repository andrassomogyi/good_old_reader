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


@interface DetailViewController () <SFSafariViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *articleDisplay;
@property (weak, nonatomic) IBOutlet UIToolbar *detailViewToolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *openInSafariBarButton;

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (void)displayArticle {
    [self.articleDisplay loadHTMLString:[Article HTMLRepresentation:self.articleContainer] baseURL:nil];
}

- (void)markAsReadOnServer {
    // Mart article read on server
    [ApiManager markArticleRead:self.articleContainer.articleId withCompletion:nil withError:nil];
}

- (IBAction)shareAction:(id)sender {
    NSString *message = @"Check out this arcticle!";
    NSString *articleToShare = self.articleContainer.canonical;
    NSArray *postItems = @[message, articleToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:postItems applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (IBAction)openInSafariAction:(id)sender {
    SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:self.articleContainer.canonical] entersReaderIfAvailable:YES];
    safariVC.delegate = self;
    [self presentViewController:safariVC animated:NO completion:nil];
}

@end
