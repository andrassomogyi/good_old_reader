//
//  DetailViewController.h
//  Good Old Reader 2
//
//  Created by András Somogyi on 2015. 02. 04..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@import SafariServices;

@class Article;

extern NSString * const MARK_AS_READ_LABEL;
extern NSString * const LEAVE_UNREAD_LABEL;

@interface DetailViewController : UIViewController

@property (strong, nonatomic) Article *articleContainer;

@end
