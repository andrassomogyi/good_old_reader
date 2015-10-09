//
//  DetailViewController.m
//  Good Old Reader 2
//
//  Created by András Somogyi on 2015. 02. 04..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//

#import "DetailViewController.h"
#import "ASArticle+HTMLRepresentation.h"


@interface DetailViewController () <SFSafariViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *articleDisplay;
@property (weak, nonatomic) IBOutlet UIToolbar *detailViewToolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *openInSafariBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *markAsReadButton;
@property (assign, nonatomic) BOOL markAsRead;

@end

NSString * const MARK_AS_READ_LABEL = @"Mark as read";
NSString * const LEAVE_UNREAD_LABEL = @"Leave unread";

@implementation DetailViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    self.markAsRead = YES;
    self.markAsReadButton.title = LEAVE_UNREAD_LABEL;
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
    [self.articleDisplay loadHTMLString:[ASArticle HTMLRepresentation:self.articleContainer] baseURL:nil];
}

- (IBAction)markAsReadToggle:(id)sender {
    self.markAsRead = !self.markAsRead;
    if (self.markAsRead) {
        self.markAsReadButton.title = LEAVE_UNREAD_LABEL;
    } else if (!self.markAsRead) {
        self.markAsReadButton.title = MARK_AS_READ_LABEL;
    }
}

- (void)markAsReadOnServer {
    // Mart article read on server
    if (self.markAsRead) {
        [self.dataController markAsRead:@[self.articleContainer.articleId] withCompletion:^(void){}];
    }
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
