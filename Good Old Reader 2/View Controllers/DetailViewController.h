//
//  DetailViewController.h
//  Good Old Reader 2
//
//  Created by András Somogyi on 2015. 02. 04..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataController.h"
@import SafariServices;

@class ASArticle;

extern NSString * const MARK_AS_READ_LABEL;
extern NSString * const LEAVE_UNREAD_LABEL;

@interface DetailViewController : UIViewController

@property (strong, nonatomic) ASArticle *articleContainer;
@property (strong, nonatomic) DataController *dataController;

@end
