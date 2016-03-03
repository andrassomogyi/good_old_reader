//
//  ApiManager.m
//  Good Old Reader 2
//
//  Created by András Somogyi on 14/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApiManager.h"
#import "EndpointResolver.h"
#import "FetchFeedOperation.h"
#import "FetchUnreadOperation.h"
#import "FeedTableViewData.h"
#import "GetTokenOperation.h"
#import "MarkAsReadOperation.h"
#import "LoginOperation.h"
#import "LogoutOperation.h"

@interface ApiManager ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation ApiManager

- (NSOperationQueue *)operationQueue {
    
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    
    return _operationQueue;
}

#pragma mark - Public functions

#pragma mark GET

- (void)fetchStreamWithCompletion:(nullable void(^)(FeedTableViewData *viewData))completion withError:(nullable void(^)(NSError *error))errorBlock {
    
    __block NSArray *feedItems = [[NSArray alloc] init];
    
    FetchFeedOperation *feedOperation = [[FetchFeedOperation alloc] initWithSession:nil url:[EndpointResolver URLForEndpoint:UnreadEndpoint] completion:^() {
    } error:^(NSError *error, NSInteger statusCode) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
    feedOperation.managedObjectContext = self.managedObjectContext;
    
    FetchUnreadOperation *countOperation = [[FetchUnreadOperation alloc] initWithSession:nil url:[EndpointResolver URLForEndpoint:UnreadCountEndpoint] completion:^(NSString *count) {
        
        FeedTableViewData *viewData = [[FeedTableViewData alloc] initWithArticles:feedItems title:count];
        if (completion) {
            completion(viewData);
        }
        
    } error:^(NSError *error, NSInteger statusCode) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
    
    [countOperation addDependency:feedOperation];
    
    self.operationQueue.suspended = YES;
    
    [self.operationQueue addOperation:feedOperation];
    [self.operationQueue addOperation:countOperation];
    
    self.operationQueue.suspended = NO;
    
}

- (void)fetchUnreadCountWithCompletion:(nullable void(^)(FeedTableViewData *titleOnlyViewData))completion withError:(nullable void(^)(NSError *error))errorBlock {
    FetchUnreadOperation *countOperation = [[FetchUnreadOperation alloc] initWithSession:nil url:[EndpointResolver URLForEndpoint:UnreadCountEndpoint] completion:^(NSString *count) {
        
        FeedTableViewData *viewData = [[FeedTableViewData alloc] initWithArticles:nil title:count];
        if (completion) {
            completion(viewData);
        }
        
    } error:^(NSError *error, NSInteger statusCode) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
    
    self.operationQueue.suspended = YES;
    
    [self.operationQueue addOperation:countOperation];
    
    self.operationQueue.suspended = NO;
}

- (void)getTokenWithCompletion:(void(^)(NSData *token))completion withError:(void(^)(NSError *error))errorBlock {
    
    GetTokenOperation *operation = [[GetTokenOperation alloc] initWithSession:nil url:[EndpointResolver URLForEndpoint:GetTokenEndpoint] completion:^(NSData *token) {
        if (completion) {
            completion(token);
        }
    } error:^(NSError *error, NSInteger statusCode) {
        errorBlock(error);
    }];
    
    self.operationQueue.suspended = YES;
    
    [self.operationQueue addOperation:operation];
    
    self.operationQueue.suspended = NO;
}

#pragma mark POST
- (void)markArticleRead:(NSArray *)article withCompletion:(void(^)(NSData *))completion withError:(void(^)(NSError *))errorBlock {
    NSString *articleIdString = [article componentsJoinedByString:@"&i="];
    NSURL *url = [EndpointResolver URLForEndpoint:MarkAsReadEndpoint];
    NSDictionary *postData = @{@"i": articleIdString,
                               @"a": @"user/-/state/com.google/read",
                               @"output": @"json"};
    MarkAsReadOperation *markAsReadOperation = [[MarkAsReadOperation alloc] initWithSession:nil url:url postData:postData completion:^(NSData *data) {
        if (completion) {
            completion(data);
        }
    } error:^(NSError *error, NSInteger statusCode) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
    
    self.operationQueue.suspended = YES;
    [self.operationQueue addOperation:markAsReadOperation];
    self.operationQueue.suspended = NO;
}

- (void)logoutWithCompletion:(void(^)(NSData *data))completion withError:(void(^)(NSError *error))errorBlock {
    NSURL *url = [EndpointResolver URLForEndpoint:ClientLogoutEndpoint];
    LogoutOperation *logoutOperation = [[LogoutOperation alloc] initWithSession:nil url:url completion:^(NSData *data) {
        if (completion) {
            completion(data);
        }
    } error:^(NSError *error, NSInteger statusCode) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
    
    self.operationQueue.suspended = YES;
    [self.operationQueue addOperation:logoutOperation];
    self.operationQueue.suspended = NO;
}

- (void)loginUser:(NSString *)username withPassword:(NSString *)password completion:(void(^)(NSData *))completion error:(void(^)(NSError *))errorBlock {
    NSURL *url = [EndpointResolver URLForEndpoint:ClientLoginEndpoint];
    NSDictionary *postData = @{@"client": @"YourAppName",
                               @"accountType": @"HOSTED_OR_GOOGLE",
                               @"service": @"reader",
                               @"Email": username,
                               @"Passwd": password,
                               @"output": @"json"};
    LoginOperation *loginOperation = [[LoginOperation alloc] initWithSession:nil url:url postData:postData completion:^(NSData *data) {
        if (completion) {
            completion(data);
        }
    } error:^(NSError *error, NSInteger statusCode) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
    self.operationQueue.suspended = YES;
    [self.operationQueue addOperation:loginOperation];
    self.operationQueue.suspended = NO;
}

@end
