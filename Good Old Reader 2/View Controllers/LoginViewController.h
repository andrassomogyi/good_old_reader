//
//  LoginViewController.h
//  Good Old Reader 2
//
//  Created by András Somogyi on 2015. 03. 03..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataController.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) DataController *dataController;

@end
