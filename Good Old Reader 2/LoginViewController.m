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
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@end

@implementation LoginViewController
#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self failedLogin];
    [self registerforKeyBoardNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - Actions
- (IBAction)loginButtonPressed:(UIButton *)sender {
    [ApiManager loginUser:self.loginEmailTextField.text withPassword:self.loginPassTextField.text completion:^(NSData *data) {
        [self succesfullLogin];
    } error:^(NSError *error) {
        [self loginError];
    }];
    [self loadingInProgress];
}

- (void)loadingInProgress {
    self.loginButton.hidden = YES;
    self.loginActivityIndicatiorSpinner.hidden = NO;
    [self.loginActivityIndicatiorSpinner startAnimating];
}

- (void)succesfullLogin {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)failedLogin {
    self.loginMessageLabel.text = @"Login";
    self.loginButton.hidden = NO;
    self.loginActivityIndicatiorSpinner.hidden = YES;
    [self.loginActivityIndicatiorSpinner stopAnimating];
}

- (void)loginError {
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

- (void)registerforKeyBoardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) keyboardWasShown:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    self.scrollView.contentInset = contentInset;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= (keyboardSize.height);
    if (!CGRectContainsPoint(aRect, self.loginButton.frame.origin)) {
        [self.scrollView scrollRectToVisible:self.loginButton.frame animated:YES];
    }
}

- (void) keyboardWillBeHidden:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

@end
