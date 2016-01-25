//
//  AppDelegate.m
//  Good Old Reader 2
//
//  Created by András Somogyi on 2015. 01. 25..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//

#import "AppDelegate.h"
#import "ApiManager.h"
#import "FeedTableViewController.h"
#import "SetupViewController.h"

@interface AppDelegate ()

@property (strong, nonatomic) FeedTableViewController *rootVC;
@property (strong, readwrite) PersistenceManager *persistenceController;

- (void)completeUserInterface;

@end

@implementation AppDelegate

#pragma mark - Application lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"Launched in background %d", UIApplicationStateBackground == application.applicationState);
    
    [self initNavigationControllerWithView:nil];
    
    // Setting up background fetch
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    // Shortcut items
    UIApplicationShortcutItem *shortcut = [[UIApplicationShortcutItem alloc] initWithType:@"SetupType" localizedTitle:@"Setup"];
    [UIApplication  sharedApplication].shortcutItems = @[shortcut];
    
    return YES;
}

-(void)completeUserInterface {
    // Core Data initialized
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self.persistenceController save];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.persistenceController save];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self.persistenceController save];
}

#pragma mark - Core Data helpers

- (NSURL*)storeURL {
    NSURL* documentsDirectory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    return [documentsDirectory URLByAppendingPathComponent:@"GoodOldReader.sqlite"];
}

- (NSURL*)modelURL {
    return [[NSBundle mainBundle] URLForResource:@"Article" withExtension:@"momd"];
}

#pragma mark - Other application delegate methods

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    ApiManager *apiManager = [[ApiManager alloc] init];
//    DataController *dataController = [[DataController alloc] initWithApiManager:apiManager];
//    [dataController getUnreadWithCompletion:^(NSArray *unreadArticles) {
//        self.rootVC.articleArray = unreadArticles;
//        [self.rootVC  updateFeedFromBackgroundFetch:completionHandler];
//    }];
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    self.backgroundSessionCompletionHandler = completionHandler;
}

-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    NSLog(@"%@",shortcutItem);

    SetupViewController *setupVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SetupViewController"];
    [self initNavigationControllerWithView:setupVC];
    
    completionHandler(YES);
}

-(DataController *)getDataController {
    CoreDataStack *coreDataStack = [[CoreDataStack alloc] initWithStoreURL:[self storeURL] modelURL:[self modelURL] withCallback:^{
        [self completeUserInterface];
    }];
    
    PersistenceManager *persistenceManager = [[PersistenceManager alloc] initWithCoreDataStack:coreDataStack];

    ApiManager *apiManager = [[ApiManager alloc] init];
    
    DataController *dataController = [[DataController alloc] initWithApiManager:apiManager persistenceManager:persistenceManager];
    dataController.managedObjectContext = coreDataStack.managedObjectContext;
    
    return dataController;
}

-(void)initNavigationControllerWithView:(NSObject * _Nullable)view{
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    self.rootVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FeedTableViewController"];
    self.rootVC.dataController = [self getDataController];
    if ([[view class] isSubclassOfClass:[UIViewController class]]) {
        navController.viewControllers = @[self.rootVC,view];
    } else {
        navController.viewControllers = @[self.rootVC];
    }
}

@end
