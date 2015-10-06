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

@interface DataController ()

@end

@implementation DataController

- (instancetype) initWithApiManager:(ApiManager *)apiManager persistenceManager:(PersistenceManager *) persistenceManager
{
    self = [super init];
    if (self) {
        _apiManager = apiManager;
        _apiManager.managedObjectContext = _managedObjectContext;
        _persistenceManager = persistenceManager;
    }
    return self;
}

- (void)getUnreadWithCompletion:(void (^)(FeedTableViewData *))completion {
    // TODO: persistence manager, fetch
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"published" ascending:YES]];;
    NSFetchedResultsController *articleFetchedResultsController = [self.persistenceManager getFetchedResultsController:@"Article" sortDescriptors:sortDescriptors];
    NSArray *fetchedArticles = [articleFetchedResultsController fetchedObjects];
    NSArray *tempArray = [self.managedObjectContext executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Article"] error:NULL];

    if (tempArray.count == 0) {
        // ha nil, akkor fetch from server
        self.apiManager.managedObjectContext = self.managedObjectContext; // TODO
        [self.apiManager fetchStreamWithCompletion:^(FeedTableViewData * _Nonnull viewData) {
            NSError *saveError = nil;
            [self.managedObjectContext save:&saveError];
            completion(viewData);
        } withError:^(NSError * _Nonnull error) {
            
        }];
        // completionben save moc
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
            completion();
        } withError:^(NSError * _Nonnull error) {
            //
        }];
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
