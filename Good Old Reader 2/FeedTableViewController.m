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

@interface FeedTableViewController ()
@property (nonatomic, copy) NSDictionary *jsonFeed;
@property (nonatomic, strong) NSMutableDictionary *articleUrlDict;
@end

@implementation FeedTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Loading...";
    
    // Enable manual pull down refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(fetchStream) forControlEvents:UIControlEventValueChanged];

    // Enable setup menu button
    UIBarButtonItem *setupMenuButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(setupMenu)];
    self.navigationController.topViewController.navigationItem.rightBarButtonItem = setupMenuButton;
    setupMenuButton.enabled=TRUE;
    setupMenuButton.style=UIBarButtonSystemItemAction;

    // App group setting for Watch
    NSUserDefaults *sharedDefaults = [NSUserDefaults standardUserDefaults];
    sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.goodOldReader2"];
    [sharedDefaults setObject:@"0" forKey:@"unreadCount"];
    [sharedDefaults setObject:@"No unread article" forKey:@"recentArticle"];
    [sharedDefaults synchronize];

    // Adding a button to access QR reader view after artcile ids and urls collected
    UIBarButtonItem *qrViewButton = [[UIBarButtonItem alloc] initWithTitle:@"QR" style:UIBarButtonItemStylePlain target:self action:@selector(showQRview)];
    self.navigationController.topViewController.navigationItem.leftBarButtonItem = qrViewButton;
    qrViewButton.enabled = FALSE;
    qrViewButton.style = UIBarButtonSystemItemEdit;
    
}

- (void) showQRview {
    [self performSegueWithIdentifier:@"showQRviewSegue" sender:self];
}

- (void) viewWillAppear:(BOOL)animated {
    [self fetchStream];
    [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
    NSURL *url = [EndpointResolver URLForEndpoint:GetTokenEndpoint];
    [ApiManager queryApiUrl:url
             withCompletion:^(NSData *data) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self fetchStream];
                 });
             } withError:^(NSError *error, NSInteger statusCode) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self performSegueWithIdentifier:@"LoginModalSegue" sender:self];
                 });
             }];
}

- (void) setupMenu {
    [self performSegueWithIdentifier:@"SetupShowSegue" sender:self];
}

- (void) fetchUnreadCount {
    NSURL *url = [EndpointResolver URLForEndpoint:UnreadCountEndpoint];
    [ApiManager queryApiUrl:url
             withCompletion:^(NSData *data) {
                 NSError *jsonError;
                 NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     self.navigationItem.title = [NSString stringWithFormat:@"%@ unread",dataDictionary[@"max"]];
                 });
             } withError:^(NSError *error, NSInteger statusCode) {
             }];
}

- (void) fetchStream {
    NSURL *url = [EndpointResolver URLForEndpoint:UnreadEndpoint];
    [ApiManager queryApiUrl:url
             withCompletion:^(NSData *data) {
                 NSError *jsonError;
                 NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     self.jsonFeed = dataDictionary;
                     [self fetchUnreadCount];
                     [self.tableView reloadData];
                     [self fetchArticleUrls];
                     [self.refreshControl endRefreshing];
                 });
             } withError:^(NSError *error, NSInteger statusCode) {
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

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedPrototypeCell" forIndexPath:indexPath];
    cell.textLabel.numberOfLines = 2;
    cell.detailTextLabel.numberOfLines = 2;
    cell.textLabel.text = [[[self.jsonFeed objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"title"];

    // Fetching article text from JSON, stripping HTML tags, removing leading whitespaces and newlines
    NSString *fullSummary = [[[[self.jsonFeed objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"summary"] objectForKey:@"content"];

    NSString *shortSummary = [self stripTags:fullSummary];
    shortSummary = [shortSummary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // To avoid exception when summary is shorter than 200 characters
    if ([shortSummary length] > 200) {
        shortSummary = [shortSummary substringToIndex:200];
    }

    cell.detailTextLabel.text = shortSummary;
    
    // Adding long tap gesture recognizer
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellActionSheet:)];
    [cell addGestureRecognizer:longTap];

    return cell;
}

- (void) cellActionSheet:(UIGestureRecognizer *)gestureRecognizer {
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
                                           NSDictionary *postData = @{@"i": [[[self.jsonFeed objectForKey:@"items"] objectAtIndex:tappedCellRow] objectForKey:@"id"],
                                                                      @"a": @"user/-/state/com.google/read",
                                                                      @"output": @"json"};
                                           NSURL *url = [EndpointResolver URLForEndpoint:MarkAsReadEndpoint];
                                           [ApiManager postApiUrl:url postData:postData withCompletion:^(NSData *data) {
                                               //
                                           } withError:^(NSError *error, NSInteger statusCode) {
                                               //
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

#pragma mark - Navigation
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DetailSeque"]) {
        // Get the sender object, aka. tapped cell
        NSIndexPath *indexPath = [self.tableView indexPathForCell: sender];
        // Mart article read on server
        NSDictionary *postData = @{@"i": [[[self.jsonFeed objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"id"],
                                   @"a": @"user/-/state/com.google/read",
                                   @"output": @"json"};
        NSURL *url = [EndpointResolver URLForEndpoint:MarkAsReadEndpoint];
        [ApiManager postApiUrl:url postData:postData withCompletion:^(NSData *data) {
            //
        } withError:^(NSError *error, NSInteger statusCode) {
            //
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

- (NSString *) stripTags:(NSString *)stringToStrip {
    NSMutableString *html = [NSMutableString stringWithCapacity:[stringToStrip length]];

    NSScanner *scanner = [NSScanner scannerWithString:stringToStrip];
    scanner.charactersToBeSkipped = nil;
    NSString *tempText = nil;

    while (![scanner isAtEnd])
    {
        [scanner scanUpToString:@"<" intoString:&tempText];

        if (tempText != nil)
            [html appendString:tempText];

        [scanner scanUpToString:@">" intoString:nil];

        if (![scanner isAtEnd])
            [scanner setScanLocation:[scanner scanLocation] + 1];

        tempText = nil;
    }

    return html;
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

@end
