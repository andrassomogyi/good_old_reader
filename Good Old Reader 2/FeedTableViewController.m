//
//  FeedTableViewController.m
//  Good Old Reader 2
//
//  Created by András Somogyi on 2015. 01. 25..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//

#import "FeedTableViewController.h"
#import "Http.h"
#import "DetailViewController.h"

@interface FeedTableViewController ()

@end

#pragma mark - Context identifiers for KVO on HTTP communication
static void *STREAMContext = &STREAMContext;
static void *UNREADCOUNTContext = &UNREADCOUNTContext;

Http *stream;
Http *unread;
NSDictionary *jsonFeed;

@implementation FeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
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

- (void)fetchUnreadCount {
    unread = [[Http alloc] initWithUrlGet:@"https://theoldreader.com/reader/api/0/unread-count?output=json"];
    [unread addObserver:self forKeyPath:@"dataReady" options:NSKeyValueObservingOptionNew context:UNREADCOUNTContext];
    // TODO: Detect and handle network erros
    //    [unread addObserver:self forKeyPath:@"NetworkError" options:NSKeyValueObservingOptionNew context:NETWORKERRORContext];
    
}

- (void)fetchStream {
    // Reading list only fresh, max 1000 item
    stream = [[Http alloc] initWithUrlGet:@"https://theoldreader.com/reader/atom/user/-/state/com.google/reading-list?xt=user/-/state/com.google/read&output=json&n=1000"];
    [stream addObserver:self forKeyPath:@"dataReady" options:NSKeyValueObservingOptionNew context:STREAMContext];
    // TODO: Detect and handle network erros
    //    [stream addObserver:self forKeyPath:@"networkError" options:NSKeyValueObservingOptionNew context:NETWORKERRORContext];
}

- (void)didReceiveMemoryWarning {
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
    return [[jsonFeed objectForKey:@"items"] count];}

#pragma mark - HTTP communication observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
#pragma mark Unread count observer
    if (context == UNREADCOUNTContext && [keyPath isEqualToString:@"dataReady"]) {
        NSError *error = nil;
        NSDictionary *jsonReceivedData = [NSJSONSerialization JSONObjectWithData: [unread receivedData] options: NSJSONReadingMutableContainers error: &error];
        if (!jsonReceivedData) {
            NSLog(@"json error: %@",error);
        }
        else {
            NSString *unreadCountString = jsonReceivedData[@"max"];
            int unreadCountInteger = [unreadCountString intValue];
            NSString *navigationItemTitle = [NSString stringWithFormat:@"%d unread",unreadCountInteger];
            self.navigationItem.title = navigationItemTitle;
        }
        @try {
            [unread removeObserver:self forKeyPath:@"dataReady" context:UNREADCOUNTContext];
        }
        @catch (NSException *exception) {NSLog(@"Exception handled: %@",exception);
        }
    }
#pragma mark Stream observer
    // Observing data when acquiring stream
    if (context == STREAMContext && [keyPath isEqualToString:@"dataReady"]) {
        NSError *error = nil;
        jsonFeed = [NSJSONSerialization JSONObjectWithData: [stream receivedData] options: NSJSONReadingMutableContainers error: &error];
        if (!jsonFeed) {
            NSLog(@"Error parsing JSON: %@", error);}
        /* FOR DEBUG PURPOSES ONLY
         else {
         for(NSDictionary *item in jsonFeed) {
         NSLog(@"Item: %@", item);
         }
         
         NSString *items = jsonFeed[@"items"];
         NSString *title = [[[jsonFeed objectForKey:@"items"] objectAtIndex:0] objectForKey:@"title"];
         NSString *author = [[[jsonFeed objectForKey:@"items"] objectAtIndex:0] objectForKey:@"author"];
         NSString *summary = [[[[[jsonFeed objectForKey:@"items"] objectAtIndex:0] objectForKey:@"summary"] objectForKey:@"content"] substringToIndex:100];
         NSLog(@"%@",title);
         NSLog(@"%@",author);
         NSLog(@"%@",summary);
         */
        
        @try {
            [stream removeObserver:self forKeyPath:@"dataReady" context:STREAMContext];
        }
        @catch (NSException *exception) {NSLog(@"Exception handled: %@",exception);}
        [self.tableView reloadData];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedPrototypeCell" forIndexPath:indexPath];
    cell.textLabel.numberOfLines = 2;
    cell.detailTextLabel.numberOfLines = 2;
    cell.textLabel.text = [[[jsonFeed objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    // Fetching article text from JSON, stripping HTML tags, removing leading whitespaces and newlines
    NSString *fullSummary = [[[[jsonFeed objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"summary"] objectForKey:@"content"];
    fullSummary = [self stripTags:fullSummary];
    fullSummary = [fullSummary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // To avoid exception when summary is shorter than 200 characters
    NSString *shortSummary;
    if ([fullSummary length] > 200) {
        shortSummary = [fullSummary substringToIndex:200];
    }
    else {
        shortSummary = fullSummary;
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
    if ([segue.identifier isEqualToString:@"DetailSeque"]) {
        // Get the destination view controller of the seque
        DetailViewController *detailViewController = segue.destinationViewController;
        // Get the sender object, aka. tapped cell
        NSIndexPath *indexPath = [self.tableView indexPathForCell: sender];
        
        // Pass the text and title of the article in a dictionary
        NSDictionary *tappedArticle = @{
                                        @"Title":    [[[jsonFeed objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"title"],
                                        @"Content":  [[[[jsonFeed objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"summary"] objectForKey:@"content"]
                                        };
        detailViewController.articleContainer = tappedArticle;
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
