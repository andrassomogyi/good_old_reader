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
    [self.articleDisplay loadHTMLString:[Article HTMLRepresentation:self.articleContainer] baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

