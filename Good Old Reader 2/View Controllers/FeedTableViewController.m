//
//  FeedTableViewController.m
//  Good Old Reader 2
//
//  Created by András Somogyi on 2015. 01. 25..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//

#import "FeedTableViewController.h"
#import "DetailViewController.h"
#import "QRreaderViewController.h"
#import "ApiManager.h"
#import "EndpointResolver.h"
#import <PersistenceKit/PersistenceKit.h>
#import "AutoHeightTableViewCell.h"
#import "NSString+ShortSummary.h"
#import "Article.h"

@interface FeedTableViewController ()
@property (nonatomic, copy) NSArray *articleArray;
@property (nonatomic, copy) NSDictionary *jsonFeed;
@property (nonatomic, strong) NSMutableDictionary *articleUrlDict;
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
    [self.refreshControl addTarget:self action:@selector(fetchStream) forControlEvents:UIControlEventValueChanged];

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
    
    id unreadCount = [PersistenceManager load:@"unreadCount" fromGroup:nil];
    
    // DEMO Logging last sessions unread count
    NSLog(@"Application closed with %@ unread articles.", unreadCount);
    NSLog(@"Application closed with %@ unread articles. (App group)", [PersistenceManager load:@"unreadCount" fromGroup:@"group.goodOldReader2"]);
}

- (void)viewWillAppear:(BOOL)animated {
    [self fetchStream];
}

- (void)viewDidAppear:(BOOL)animated {
    [ApiManager getTokenWithCompletion:nil withError:^(NSError *error) {
        [self performSegueWithIdentifier:@"LoginModalSegue" sender:self];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Actions
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
                                           Article *article = self.articleArray[tappedCellRow];
                                           [ApiManager markArticleRead:article.articleId withCompletion:^(NSData *response) {
                                               [self fetchStream];
                                               [self.tableView reloadData];
                                           } withError:^(NSError *error) {
                                               ;
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
- (void)fetchUnreadCount {
    [ApiManager fetchUnreadCountWithCompletion:^(NSString *unreadCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.title = [NSString stringWithFormat:@"%@ unread",unreadCount];
        });
    } withError:nil];
}

- (void)fetchStream {
    [ApiManager fetchStreamWithCompletion:^(NSArray *articleArray) {
        self.articleArray = articleArray;
        [self fetchUnreadCount];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    } withError:nil];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.articleArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AutoHeightTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedPrototypeCell" forIndexPath:indexPath];
    Article *article = self.articleArray[indexPath.row];
    cell.cellTitleLabel.text = article.title;
    
    // Setting cell content
    cell.cellDetailLabel.text = [article  shortSummary];
    cell.cellSiteLabel.text = [article origin_title];
    cell.cellPublishedLabel.text = [article datePublished];

    // Adding long tap gesture recognizer
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellActionSheet:)];
    [cell addGestureRecognizer:longTap];

    return cell;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DetailSeque"]) {
        // Get the sender object, aka. tapped cell
        NSIndexPath *indexPath = [self.tableView indexPathForCell: sender];
        Article *article = self.articleArray[indexPath.row];
        
        // Get the destination view controller of the seque
        DetailViewController *detailViewController = segue.destinationViewController;
        // Pass the text and title of the article in a dictionary
        detailViewController.articleContainer = article;
    }
    if ([segue.identifier isEqualToString:@"showQRviewSegue"]) {
        QRreaderViewController *qrViewController = segue.destinationViewController;
        qrViewController.articleUrlDict = self.articleUrlDict;
    }
}

@end
