//
//  DataController.h
//  Good Old Reader 2
//
//  Created by Somogyi András on 28/09/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PersistenceKit/PersistenceManager.h>

@class ApiManager;
@class FeedTableViewData;

@interface DataController : NSObject

@property (nonatomic, strong, readonly) ApiManager *apiManager;
@property (nonatomic, strong) PersistenceManager *persistenceManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (instancetype) initWithApiManager:(ApiManager *)apiManager persistenceManager:(PersistenceManager *) persistenceManager;
- (void)getUnreadWithManualRefresh:(BOOL)isManualRefresh withCompletion:(void (^)(FeedTableViewData *)) completion;
- (void)getTokenWithCompletion:(void(^)(NSData *token))completion withError:(void(^)(void))errorBlock;
- (void)markAsRead:(NSArray *)article withCompletion:(void(^)(void))completion;
- (void)loginUser:(NSString *)user password:(NSString *)password withCompletion:(void(^)(void))completion withError:(void(^)(void))errorBlock;
- (void)logoutUserWithCompletion:(void(^)(void))completion;

@end
