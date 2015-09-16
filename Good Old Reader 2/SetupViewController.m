//
//  SetupViewController.m
//  Good Old Reader 2
//
//  Created by András Somogyi on 2015. 04. 23..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//

#import "SetupViewController.h"
#import "EndpointResolver.h"
#import "ApiManager.h"

@interface SetupViewController ()
- (IBAction)logoutButton:(UIButton *)sender;

@end

@implementation SetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)logoutButton:(UIButton *)sender {
    NSURL *url = [EndpointResolver URLForEndpoint:ClientLogoutEndpoint];
    [ApiManager queryApiUrl:url
             withCompletion:^(NSData *data) {
                 [self.navigationController popToRootViewControllerAnimated:YES];
             } withError:^(NSError *error, NSInteger statusCode) {
                 //
                 NSLog(@"Error");
             }];
}
@end
