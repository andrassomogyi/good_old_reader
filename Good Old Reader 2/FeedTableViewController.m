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
#import "AFNetworking.h"

@interface FeedTableViewController ()
@end

@implementation FeedTableViewController {
    NSDictionary *jsonFeed;
    UIRefreshControl *refreshControl;
}

- (void) viewDidLoad {
    [super viewDidLoad];

    // Enable manual pull down refresh
    refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(fetchStream) forControlEvents:UIControlEventValueChanged];

    // Enable setup menu button
    UIBarButtonItem *setupMenuButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(setupMenu)];
    self.navigationController.topViewController.navigationItem.rightBarButtonItem = setupMenuButton;
    setupMenuButton.enabled=TRUE;
    setupMenuButton.style=UIBarButtonSystemItemAction;
}

- (void) viewDidAppear:(BOOL)animated {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"token"] == nil) {
        // No user credentials found
        [self.tableView setHidden:YES];
        [self performSegueWithIdentifier:@"LoginModalSegue" sender:self];
        [self.tableView setHidden:NO];
    } else {
        [self fetchStream];
        [self fetchUnreadCount];
    }
}

- (void) setupMenu {
        [self performSegueWithIdentifier:@"SetupShowSegue" sender:self];
}

- (NSInteger) fetchUnreadCount {
    NSInteger unreadCount = 0;
    AFHTTPRequestOperationManager *unreadCountManager = [AFHTTPRequestOperationManager manager];
    [unreadCountManager GET:@"https://theoldreader.com/reader/api/0/unread-count?output=json"
                 parameters:nil
                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        self.navigationItem.title = [NSString stringWithFormat:@"%@ unread",responseObject[@"max"]];
                    }
                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        // TODO
                    }];
    return unreadCount;
}

- (void) fetchStream {
    // Reading list: only fresh, max 1000 item
    AFHTTPRequestOperationManager *streamManager = [AFHTTPRequestOperationManager manager];
    [streamManager GET:@"https://theoldreader.com/reader/atom/user/-/state/com.google/reading-list?xt=user/-/state/com.google/read&output=json&n=1000"
            parameters:nil
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   jsonFeed = responseObject;
                   [self fetchUnreadCount];
                   [self.tableView reloadData];
                   [refreshControl endRefreshing];
               }
               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   // TODO
               }];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // TODO: remove me
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[jsonFeed objectForKey:@"items"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedPrototypeCell" forIndexPath:indexPath];
    cell.textLabel.numberOfLines = 2;
    cell.detailTextLabel.numberOfLines = 2;
    cell.textLabel.text = [[[jsonFeed objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"title"];

    // Fetching article text from JSON, stripping HTML tags, removing leading whitespaces and newlines
    NSString *fullSummary = [[[[jsonFeed objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"summary"] objectForKey:@"content"];

    NSString *shortSummary = [self stripTags:fullSummary];
    shortSummary = [shortSummary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // To avoid exception when summary is shorter than 200 characters
    if ([shortSummary length] > 200) {
        shortSummary = [shortSummary substringToIndex:200];
    }

    cell.detailTextLabel.text = shortSummary;

    // Parsing the images from the summaries
    // Makes the tableview lag, kept for historical reasons only
    //
    //    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    //    NSArray *matches = [linkDetector matchesInString:fullSummary options:0 range:NSMakeRange(0, [fullSummary length])];
    //    for (NSTextCheckingResult *match in matches) {
    //        NSString *possibleImage = [[match URL] absoluteString];
    //        if (([possibleImage rangeOfString:@".jpg"].location != NSNotFound) ||
    //            ([possibleImage rangeOfString:@".gif"].location != NSNotFound) ||
    //            ([possibleImage rangeOfString:@".png"].location != NSNotFound)) {
    //                cell.imageView.image  = [UIImage imageWithData:[NSData dataWithContentsOfURL:[match URL]]];
    //
    //        }
    //    }
    return cell;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self fetchStream];
    if ([segue.identifier isEqualToString:@"DetailSeque"]) {
        // Get the destination view controller of the seque
        DetailViewController *detailViewController = segue.destinationViewController;
        // Get the sender object, aka. tapped cell
        NSIndexPath *indexPath = [self.tableView indexPathForCell: sender];
        // Pass the text and title of the article in a dictionary
        detailViewController.articleContainer = [[jsonFeed objectForKey:@"items"] objectAtIndex:indexPath.row];
    }
}

- (NSString *)stripTags:(NSString *)stringToStrip
{
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
