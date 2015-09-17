//
//  ApiManager.h
//  Good Old Reader 2
//
//  Created by András Somogyi on 14/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApiManager : NSObject

+ (void)fetchUnreadCountWithCompletion:(void(^)(NSString *unreadCount))completion withError:(void(^)(NSError *error))errorBlock;
+ (void)fetchStreamWithCompletion:(void(^)(NSDictionary *streamData))completion withError:(void(^)(NSError *error))errorBlock;
+ (void)markArticleRead:(NSString *)articleId withCompletion:(void(^)(NSData *response))completion withError:(void(^)(NSError *error))errorBlock;
+ (void)getTokenWithCompletion:(void(^)(NSData *token))completion withError:(void(^)(NSError *error))errorBlock;
+ (void)logoutWithCompletion:(void(^)(NSData *data))completion withError:(void(^)(NSError *error))errorBlock;
+ (void)loginUser:(NSString *)username withPassword:(NSString *)password completion:(void(^)(NSData *data))completion error:(void(^)(NSError *error))errorBlock;


+ (void)queryApiUrl:(NSURL *)url withCompletion:(void(^)(NSData *data))completion withError:(void(^)(NSError *error, NSInteger statusCode))errorBlock;
+ (void)postApiUrl:(NSURL *)url postData:(NSDictionary *)dataDictionary withCompletion:(void(^)(NSData *data))completion withError:(void(^)(NSError *error, NSInteger statusCode))errorBlock;

@end
