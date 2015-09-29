//
//  DataController.h
//  Good Old Reader 2
//
//  Created by Somogyi András on 28/09/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataController : NSObject

- (void)getUnreadWithCompletion:(void(^)(NSArray *unreadArticles))completion;
- (void)getUnreadCountWithCompletion:(void(^)(NSString *unreadCount))completion;
- (void)getTokenWithCompletion:(void(^)(NSData *token))completion withError:(void(^)(void))errorBlock;
- (void)markAsRead:(NSString *)article withCompletion:(void(^)(void))completion;
- (void)loginUser:(NSString *)user password:(NSString *)password withCompletion:(void(^)(void))completion;
- (void)logoutUserWithCompletion:(void(^)(void))completion;

@end
