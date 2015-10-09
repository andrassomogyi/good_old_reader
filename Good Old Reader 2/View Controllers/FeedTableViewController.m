//
//  FeedTableViewController.m
//  Good Old Reader 2
//
//  Created by András Somogyi on 2015. 01. 25..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//

#import <PersistenceKit/PersistenceKit.h>
#import "FeedTableViewController.h"
#import "QRreaderViewController.h"
#import "AutoHeightTableViewCell.h"
#import "ASArticle.h"
#import "DataController.h"
#import "SetupViewController.h"
#import "LoginViewController.h"
#import "FeedTableViewData.h"

@interface FeedTableViewController ()
@property (nonatomic, copy) NSDictionary *jsonFeed;
@end

@implementation FeedTableViewController
#pragma mark - View lifecycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.title = @"Loading...";
    
    // Settings for auto-height cells
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Enable manual pull down refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(manualFetchNewData) forControlEvents:UIControlEventValueChanged];

    // Enable setup menu button
    UIBarButtonItem *setupMenuButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(setupMenu)];
    self.navigationController.topViewController.navigationItem.rightBarButtonItem = setupMenuButton;
    setupMenuButton.enabled=TRUE;
    setupMenuButton.style=UIBarButtonSystemItemAction;

    // Adding a button to access QR reader view after artcile ids and urls collected
    UIBarButtonItem *qrViewButton = [[UIBarButtonItem alloc] initWithTitle:@"QR" style:UIBarButtonItemStylePlain target:self action:@selector(showQRview)];
    self.navigationController.topViewController.navigationItem.leftBarButtonItem = qrViewButton;
    qrViewButton.enabled = FALSE;
    qrViewButton.style = UIBarButtonSystemItemEdit;
    
//    id unreadCount = [PersistenceManager load:@"unreadCount" fromGroup:nil];
//    
//    // DEMO Logging last sessions unread count
//    NSLog(@"Application closed with %@ unread articles.", unreadCount);
//    NSLog(@"Application closed with %@ unread articles. (App group)", [PersistenceManager load:@"unreadCount" fromGroup:@"group.goodOldReader2"]);
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.dataController getTokenWithCompletion:^(NSData *token) {
        [self fetchNewData];
    } withError:^{
        [self performSegueWithIdentifier:@"LoginModalSegue" sender:self];
    }];
}

#pragma mark - Actions

-(void)updateFeedFromBackgroundFetch:(void (^)(UIBackgroundFetchResult))completionHandler {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fetchNewData];
        completionHandler(UIBackgroundFetchResultNewData);
    });
}

- (void)showQRview {
    [self performSegueWithIdentifier:@"showQRviewSegue" sender:self];
}

- (void)setupMenu {
    [self performSegueWithIdentifier:@"SetupShowSegue" sender:self];
}

- (void)cellActionSheet:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    UITableViewCell *tappedCell = (UITableViewCell *) gestureRecognizer.view;
    NSString *alertTitle = @"Mark article as read";
    NSString *alertString = @"Do you want to mark as read?";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertString preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *markAsReadAction = [UIAlertAction
                                       actionWithTitle:@"Mark as read"
                                       style:UIAlertActionStyleDestructive
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSInteger tappedCellRow = [self.tableView indexPathForCell:tappedCell].row;
                                           ASArticle *article = self.articleArray[tappedCellRow];
                                           [self.dataController markAsRead:@[article.articleId] withCompletion:^(void) {
                                               [self fetchNewData];
                                           }];
                                       }];;
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       // Doing nothing
                                   }];;
    [alertController addAction:markAsReadAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Feed handling

- (void)fetchNewData {
    [self.dataController getUnreadWithManualRefresh:NO withCompletion:^(FeedTableViewData *data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.title = [NSString stringWithFormat:@"%@ unread", data.title];
            self.articleArray = data.articleArray;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    }];
}

- (void) manualFetchNewData {
    [self.dataController getUnreadWithManualRefresh:YES withCompletion:^(FeedTableViewData *data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.title = [NSString stringWithFormat:@"%@ unread", data.title];
            self.articleArray = data.articleArray;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.articleArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AutoHeightTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedPrototypeCell" forIndexPath:indexPath];
    ASArticle *article = self.articleArray[indexPath.row];
    cell.cellTitleLabel.text = article.title;
    
    // Setting cell content
    cell.cellDetailLabel.text = [article  shortSummary];
    cell.cellSiteLabel.text = [article originTitle];
    cell.cellPublishedLabel.text = [article datePublished];

    // Adding long tap gesture recognizer
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellActionSheet:)];
    [cell addGestureRecognizer:longTap];

    return cell;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DetailSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell: sender];
        self.selectedArticle = self.articleArray[indexPath.row];
    }
}

@end
