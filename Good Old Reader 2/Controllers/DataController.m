//
//  DataController.m
//  Good Old Reader 2
//
//  Created by Somogyi András on 28/09/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "DataController.h"
#import "ApiManager.h"
#import "FeedTableViewData.h"
#import "ASArticle+PersistenceUtils.h"
#import "Article.h"
#import "Article+CoreDataProperties.h"

@interface DataController ()

@end

@implementation DataController

- (instancetype)initWithApiManager:(ApiManager *)apiManager persistenceManager:(PersistenceManager *) persistenceManager {
    self = [super init];
    if (self) {
        _apiManager = apiManager;
        _apiManager.managedObjectContext = _managedObjectContext;
        _persistenceManager = persistenceManager;
    }
    return self;
}

- (void)getUnreadWithManualRefresh:(BOOL)isManualRefresh withCompletion:(void (^)(FeedTableViewData *)) completion {
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"published" ascending:NO]];
    NSArray *persistentArticles = [self.persistenceManager fetchItemsWithEntityName:[Article entityName] withPredicate:nil withSortDescriptor:sortDescriptors];
    
    if ([persistentArticles count] == 0 || isManualRefresh) {
        NSLog(@"Manual refresh: %d. Articles stored: %lu", isManualRefresh,[persistentArticles count]);
        NSBatchDeleteRequest *deleteAll = [[NSBatchDeleteRequest alloc] initWithFetchRequest:[NSFetchRequest fetchRequestWithEntityName:[Article entityName]]];
        [self.managedObjectContext.persistentStoreCoordinator executeRequest:deleteAll withContext:self.managedObjectContext error:nil];
        self.apiManager.managedObjectContext = self.managedObjectContext;
        [self.apiManager fetchStreamWithCompletion:^(FeedTableViewData * _Nonnull viewData) {
            NSError *saveError = nil;
            [self.managedObjectContext save:&saveError];
            completion(viewData);
        } withError:^(NSError * _Nonnull error) {
        }];
    } else {
        NSLog(@"Showing stored articles");
        FeedTableViewData *viewData = [[FeedTableViewData alloc] initWithArticles:[ASArticle modelRepresentationForItems:persistentArticles] title:[NSString stringWithFormat:@"%lu", (unsigned long)[persistentArticles count]]];
        completion(viewData);
    }
}

- (void)getTokenWithCompletion:(void(^)(NSData *))completion withError:(void(^)(void))errorBlock {
        [self.apiManager getTokenWithCompletion:^(NSData * _Nonnull token) {
            completion(token);
        } withError:^(NSError * _Nonnull error) {
            errorBlock();
        }];
}

- (void)markAsRead:(NSString *)article withCompletion:(void(^)(void))completion {
        [self.apiManager markArticleRead:article withCompletion:^(NSData * _Nonnull response) {
            NSArray *articleWithId = [self.persistenceManager fetchItemsWithEntityName:[Article entityName] withPredicate:[NSPredicate predicateWithFormat:@"(articleId MATCHES %@)", article] withSortDescriptor:nil];
            [self markAsReadLocally:article];
            [self.managedObjectContext deleteObject:articleWithId[0]];
            NSError *saveError = nil;
            [self.managedObjectContext save:&saveError];
            completion();
        } withError:^(NSError * _Nonnull error) {
            // We can mark as read locally even when no connection is available
            [self markAsReadLocally:article];
            NSError *saveError = nil;
            [self.managedObjectContext save:&saveError];
        }];
}

- (void) markAsReadLocally:(NSString *)article {
    NSPredicate *articleIdPredicate = [NSPredicate predicateWithFormat:@"(articleId MATCHES %@)", article];
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"published" ascending:NO]];
    NSArray *persistentArticlesWithArticleId = [self.persistenceManager fetchItemsWithEntityName:[Article entityName] withPredicate:articleIdPredicate withSortDescriptor:sortDescriptors];
    Article *articleToBeMarkedAsRead = persistentArticlesWithArticleId[0];
    NSLog(@"Article: %@ marked as read: %@",articleToBeMarkedAsRead.title, articleToBeMarkedAsRead.markedAsRead);
    articleToBeMarkedAsRead.markedAsRead = [NSNumber numberWithBool:YES];
    NSLog(@"Article: %@ marked as read: %@",articleToBeMarkedAsRead.title, articleToBeMarkedAsRead.markedAsRead);
}

- (void)loginUser:(NSString *)user password:(NSString *)password withCompletion:(void(^)(void))completion withError:(void(^)(void))errorBlock {
        [self.apiManager loginUser:user withPassword:password completion:^(NSData * _Nonnull data) {
            completion();
        } error:^(NSError * _Nonnull error) {
            errorBlock();
        }];
}

- (void)logoutUserWithCompletion:(void(^)(void))completion {
        [self.apiManager logoutWithCompletion:^(NSData * _Nonnull data) {
            completion();
        } withError:^(NSError * _Nonnull error) {
            //
        }];
}

@end
