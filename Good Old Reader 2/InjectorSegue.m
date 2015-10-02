//
//  InjectorSegue.m
//  Good Old Reader 2
//
//  Created by Somogyi András on 02/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "InjectorSegue.h"
#import "FeedTableViewController.h"
#import "LoginViewController.h"
#import "SetupViewController.h"
#import "DetailViewController.h"
#import "QRreaderViewController.h"

@implementation InjectorSegue

- (void)perform {
    if ([self.identifier isEqualToString:@"LoginModalSegue"]) {
        FeedTableViewController *sourceVC = self.sourceViewController;
        LoginViewController *destinationVC = self.destinationViewController;
        destinationVC.dataController = sourceVC.dataController;
    }
    
    if ([self.identifier isEqualToString:@"SetupShowSegue"]) {
        FeedTableViewController *sourceVC = self.sourceViewController;
        SetupViewController *destinationVC = self.destinationViewController;
        destinationVC.dataController = sourceVC.dataController;
    }

    if ([self.identifier isEqualToString:@"DetailSegue"]) {
        FeedTableViewController *sourceVC = self.sourceViewController;
        DetailViewController *destinationVC = self.destinationViewController;
        destinationVC.articleContainer = sourceVC.selectedArticle;
        destinationVC.dataController = sourceVC.dataController;
    }
    
    if ([self.identifier isEqualToString:@"showQRviewSegue"]) {
        FeedTableViewController *sourceVC = self.sourceViewController;
        QRreaderViewController *destinationVC = self.destinationViewController;
        destinationVC.dataController = sourceVC.dataController;
        destinationVC.articleUrlDict = sourceVC.articleUrlDict;
    }
    
    [super perform];
}

@end
