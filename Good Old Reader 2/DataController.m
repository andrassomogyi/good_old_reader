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

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)getUnreadWithCompletion:(void(^)(NSArray *))completion {
    if (completion) {
        [ApiManager fetchStreamWithCompletion:^(NSArray *articleArray) {
            completion(articleArray);
        } withError:nil];
    }
}

- (void)getUnreadCountWithCompletion:(void(^)(NSString *))completion {
    if (completion) {
        [ApiManager fetchUnreadCountWithCompletion:^(NSString * _Nonnull unreadCount) {
            completion(unreadCount);
        } withError:^(NSError * _Nonnull error) {
            //
        }];
    }
}

- (void)getTokenWithCompletion:(void(^)(NSData *))completion withError:(void(^)(void))errorBlock {
    if (completion) {
        [ApiManager getTokenWithCompletion:^(NSData * _Nonnull token) {
            completion(token);
        } withError:^(NSError * _Nonnull error) {
            errorBlock();
        }];
    }
}

- (void)markAsRead:(NSString *)article withCompletion:(void(^)(void))completion {
    if (completion) {
        [ApiManager markArticleRead:article withCompletion:^(NSData * _Nonnull response) {
            completion();
        } withError:^(NSError * _Nonnull error) {
            //
        }];
    }
}


@end
