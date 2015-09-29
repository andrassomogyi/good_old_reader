//
//  SetupViewController.m
//  Good Old Reader 2
//
//  Created by András Somogyi on 2015. 04. 23..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//

#import "SetupViewController.h"
#import "EndpointResolver.h"
#import "DataController.h"

@interface SetupViewController ()
- (IBAction)logoutButton:(UIButton *)sender;

@end

@implementation SetupViewController
#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - Actions
- (IBAction)logoutButton:(UIButton *)sender {
    [[[DataController alloc] init] logoutUserWithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }];
}
@end
