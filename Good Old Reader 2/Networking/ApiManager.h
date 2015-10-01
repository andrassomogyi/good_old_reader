//
//  ApiManager.h
//  Good Old Reader 2
//
//  Created by András Somogyi on 14/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApiManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

NS_ASSUME_NONNULL_BEGIN

- (void)fetchUnreadCountWithCompletion:(nullable void(^)(NSString *unreadCount))completion withError:(nullable void(^)(NSError *error))errorBlock;
- (void)fetchStreamWithCompletion:(nullable void(^)(NSArray *articleArray))completion withError:(nullable void(^)(NSError *error))errorBlock;
- (void)markArticleRead:(NSString *)articleId withCompletion:(nullable void(^)(NSData *response))completion withError:(nullable void(^)(NSError *error))errorBlock;
- (void)getTokenWithCompletion:(nullable void(^)(NSData *token))completion withError:(nullable void(^)(NSError *error))errorBlock;
- (void)logoutWithCompletion:(nullable void(^)(NSData *data))completion withError:(nullable void(^)(NSError *error))errorBlock;
- (void)loginUser:(NSString *)username withPassword:(NSString *)password completion:(nullable void(^)(NSData *data))completion error:(void(^)(NSError *error))errorBlock;

- (void)queryApiUrlInBackground:(NSURL *)url;

NS_ASSUME_NONNULL_END

@end
