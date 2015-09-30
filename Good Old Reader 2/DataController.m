//
//  DataController.m
//  Good Old Reader 2
//
//  Created by Somogyi András on 28/09/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "DataController.h"
#import "ApiManager.h"

@interface DataController ()

@end

@implementation DataController

- (instancetype) initWithApiManager:(ApiManager *)apiManager {
    self = [super init];
    if (self) {
        _apiManager = apiManager;
    }
    return self;
}

- (void)getUnreadWithCompletion:(void(^)(NSArray *))completion {
        [self.apiManager fetchStreamWithCompletion:^(NSArray *articleArray) {
            completion(articleArray);
        } withError:nil];
}

- (void)getUnreadCountWithCompletion:(void(^)(NSString *))completion {
        [self.apiManager fetchUnreadCountWithCompletion:^(NSString * _Nonnull unreadCount) {
            completion(unreadCount);
        } withError:^(NSError * _Nonnull error) {
            //
        }];
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

- (void)loginUser:(NSString *)user password:(NSString *)password withCompletion:(void(^)(void))completion {
        [self.apiManager loginUser:user withPassword:password completion:^(NSData * _Nonnull data) {
            completion();
        } error:^(NSError * _Nonnull error) {
            
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
