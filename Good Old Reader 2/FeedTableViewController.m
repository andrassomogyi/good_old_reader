//
//  FeedTableViewController.m
//  Good Old Reader 2
//
//  Created by András Somogyi on 2015. 01. 25..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//
//
//         Get specific entities like:
//
//         NSString *items = jsonFeed[@"items"];
//         NSString *title = [[[jsonFeed objectForKey:@"items"] objectAtIndex:0] objectForKey:@"title"];
//         NSString *author = [[[jsonFeed objectForKey:@"items"] objectAtIndex:0] objectForKey:@"author"];
//         NSString *summary = [[[[[jsonFeed objectForKey:@"items"] objectAtIndex:0] objectForKey:@"summary"] objectForKey:@"content"] substringToIndex:100];
//
//

#import "FeedTableViewController.h"
#import "DetailViewController.h"
#import "QRreaderViewController.h"
#import "ApiManager.h"
#import "EndpointResolver.h"
#import <PersistenceKit/PersistenceKit.h>
#import "AutoHeightTableViewCell.h"
#import "NSString+ShortSummary.h"

@interface FeedTableViewController ()
@property (nonatomic, copy) NSDictionary *jsonFeed;
@property (nonatomic, strong) NSMutableDictionary *articleUrlDict;
@end

@implementation FeedTableViewController
#pragma mark - View lifecycle
- (void) viewDidLoad {
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

- (void) viewWillAppear:(BOOL)animated {
    [self fetchStream];
    [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
    [ApiManager getTokenWithCompletion:^(NSData *token) {
    } withError:^(NSError *error) {
        [self performSegueWithIdentifier:@"LoginModalSegue" sender:self];
    }];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Actions
- (void) showQRview {
    [self performSegueWithIdentifier:@"showQRviewSegue" sender:self];
}

- (void) setupMenu {
    [self performSegueWithIdentifier:@"SetupShowSegue" sender:self];
}

- (void) cellActionSheet:(UIGestureRecognizer *)gestureRecognizer {
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
                                           [ApiManager markArticleRead:[[[self.jsonFeed objectForKey:@"items"] objectAtIndex:tappedCellRow] objectForKey:@"id"] withCompletion:^(NSData *response) {
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
- (void) fetchUnreadCount {
    [ApiManager fetchUnreadCountWithCompletion:^(NSString *unreadCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.title = [NSString stringWithFormat:@"%@ unread",unreadCount];
        });
    } withError:^(NSError *error) {
    }];
}

- (void) fetchStream {
    [ApiManager fetchStreamWithCompletion:^(NSDictionary *streamData) {
        self.jsonFeed = streamData;
        [self fetchUnreadCount];
        [self fetchArticleUrls];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    } withError:^(NSError *error) {
    }];
}

- (void) fetchArticleUrls {
    self.articleUrlDict = [[NSMutableDictionary alloc] init];

    for (id item in self.jsonFeed[@"items"]) {
        NSString *href = [[item[@"canonical"] objectAtIndex:0] objectForKey:@"href"];
        NSString *articleId = item[@"id"];
        [self.articleUrlDict setValue:articleId forKey:href];
    }
    self.navigationController.topViewController.navigationItem.leftBarButtonItem.enabled = TRUE;
}

#pragma mark - Table view data source
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self.jsonFeed objectForKey:@"items"] count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AutoHeightTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedPrototypeCell" forIndexPath:indexPath];
    cell.cellTitleLabel.text = [[[self.jsonFeed objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"title"];

    // Fetching article text from JSON, stripping HTML tags, removing leading whitespaces and newlines
    NSString *fullSummary = [[[[self.jsonFeed objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"summary"] objectForKey:@"content"];

    // Setting short summary for feed view
    cell.cellDetailLabel.text = [NSString shortSummaryFromString:fullSummary summaryLength:25];

    // Adding long tap gesture recognizer
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellActionSheet:)];
    [cell addGestureRecognizer:longTap];

    return cell;
}
#pragma mark - Navigation
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DetailSeque"]) {
        // Get the sender object, aka. tapped cell
        NSIndexPath *indexPath = [self.tableView indexPathForCell: sender];
        // Mart article read on server
        [ApiManager markArticleRead:[[[self.jsonFeed objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"id"] withCompletion:^(NSData *response) {
        } withError:^(NSError *error) {
        }];
        // Get the destination view controller of the seque
        DetailViewController *detailViewController = segue.destinationViewController;
        // Pass the text and title of the article in a dictionary
        detailViewController.articleContainer = [[self.jsonFeed objectForKey:@"items"] objectAtIndex:indexPath.row];
    }
    if ([segue.identifier isEqualToString:@"showQRviewSegue"]) {
        QRreaderViewController *qrViewController = segue.destinationViewController;
        qrViewController.articleUrlDict = self.articleUrlDict;
    }
}

@end
