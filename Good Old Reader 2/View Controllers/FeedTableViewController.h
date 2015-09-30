//
//  FeedTableViewController.h
//  Good Old Reader 2
//
//  Created by András Somogyi on 2015. 01. 25..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataController.h"

@interface FeedTableViewController : UITableViewController

@property (strong, nonatomic) DataController *dataController;

@end
