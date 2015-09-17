//
//  LoginViewController.m
//  Good Old Reader 2
//
//  Created by András Somogyi on 2015. 03. 03..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//

#import "LoginViewController.h"
#import "EndpointResolver.h"
#import "ApiManager.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *loginMessageLabel;
@property (weak, nonatomic) IBOutlet UITextField *loginEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *loginPassTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginActivityIndicatiorSpinner;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self failedLogin];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)loginButtonPressed:(UIButton *)sender {
    [ApiManager loginUser:self.loginEmailTextField.text withPassword:self.loginPassTextField.text completion:^(NSData *data) {
        [self succesfullLogin];
    } error:^(NSError *error) {
        [self loginError];
    }];
    [self loadingInProgress];
}

- (void) loadingInProgress {
    self.loginButton.hidden = YES;
    self.loginActivityIndicatiorSpinner.hidden = NO;
    [self.loginActivityIndicatiorSpinner startAnimating];
}

- (void) succesfullLogin {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) failedLogin {
    self.loginMessageLabel.text = @"Login";
    self.loginButton.hidden = NO;
    self.loginActivityIndicatiorSpinner.hidden = YES;
    [self.loginActivityIndicatiorSpinner stopAnimating];
}

- (void) loginError {
    UIAlertController *loginError = [UIAlertController alertControllerWithTitle:@"Login failed"
                                                                        message:@"Bad username or password!"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try again!"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
                                                               [self failedLogin];
                                                           }];
    [loginError addAction:tryAgainAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:loginError animated:YES completion:nil];
    });
    
}

@end
