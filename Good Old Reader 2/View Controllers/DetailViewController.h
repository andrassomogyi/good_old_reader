//
//  DetailViewController.h
//  Good Old Reader 2
//
//  Created by András Somogyi on 2015. 02. 04..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article+HTMLRepresentation.h"
@import SafariServices;

@interface DetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *articleDisplay;
@property (strong, nonatomic) Article *articleContainer;
@end
