//
//  LoginViewController.m
//  Good Old Reader 2
//
//  Created by András Somogyi on 2015. 03. 03..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//

#import "LoginViewController.h"
#import "Http.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *loginMessageLabel;
@property (weak, nonatomic) IBOutlet UITextField *loginEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *loginPassTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginActivityIndicatiorSpinner;
@end

Http *loginConnection;
static void *LOGINContext = &LOGINContext;
static void *NETWORKERRORContext = &NETWORKERRORContext;

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginActivityIndicatiorSpinner.hidden = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonPressed:(UIButton *)sender {
    
    loginConnection = [[Http alloc] initWithUrlPost:@"https://theoldreader.com/accounts/ClientLogin"
                                           postData:[NSString stringWithFormat:@"client=YourAppName&accountType=HOSTED_OR_GOOGLE&service=reader&Email=%@&Passwd=%@",self.loginEmailTextField.text,self.loginPassTextField.text]];
    [loginConnection addObserver:self forKeyPath:@"dataReady" options:NSKeyValueObservingOptionNew context:LOGINContext];
    [loginConnection addObserver:self forKeyPath:@"networkError" options:NSKeyValueObservingOptionNew context:NETWORKERRORContext];
    
    
    [self loadingInProgress];
}

- (void) loadingInProgress {
    
    self.loginMessageLabel.text = @"Logging in...";
    self.loginButton.hidden = YES;
    self.loginActivityIndicatiorSpinner.hidden = NO;
    [self.loginActivityIndicatiorSpinner startAnimating];
}

- (void) succesfullLogin {
    // FIXME: store real token
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"token"];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    
}

- (void) failedLogin {
    self.loginMessageLabel.text = @"Login";
    self.loginButton.hidden = NO;
    self.loginActivityIndicatiorSpinner.hidden = YES;
    [self.loginActivityIndicatiorSpinner stopAnimating];
}

#pragma mark - HTTP communication observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
#pragma mark Network error observer
    // Observing network errors
    if (context == NETWORKERRORContext && [keyPath isEqualToString:@"networkError"]) {
        // Network error while login
        NSLog(@"Network error");
    }
    @try {
        [loginConnection removeObserver:self forKeyPath:@"networkError"];
    }
    @catch (NSException *exception) {NSLog(@"Exception handled: %@",exception);}
    
#pragma mark Login data observer
    // Observing if data is ready when logging in
    if (context == LOGINContext && [keyPath isEqualToString:@"dataReady"]) {
        NSString *fetchedString = [[NSString alloc] initWithData:[loginConnection receivedData] encoding:NSASCIIStringEncoding];
        // Log the authentication token. Debug purposes only!
        //        NSLog(@"Logindata observer: %@",fetchedString);
        if ([fetchedString rangeOfString:@"Auth="].location == NSNotFound){ // Check if fetched string contains valid token
            // Bad credentials
            @try {
                [loginConnection removeObserver:self forKeyPath:@"dataReady"];
            }
            @catch (NSException *exception) {NSLog(@"Exception handled: %@",exception);}
            [self failedLogin];
        }
        else {
            // Login succesful
            @try {
                [loginConnection removeObserver:self forKeyPath:@"dataReady"];
            }
            @catch (NSException *exception) {NSLog(@"Exception handled: %@",exception);}
            [self succesfullLogin];
        }
    }
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
