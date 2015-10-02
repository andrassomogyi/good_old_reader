//
//  FetchUnreadOperation.h
//  Good Old Reader 2
//
//  Created by József Vesza on 02/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "Operation.h"

typedef void(^unreadCompletionBlock)(NSString *count);
typedef void(^unreadErrorBlock)(NSError *error, NSInteger statusCode);

@interface FetchUnreadOperation : Operation

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSURLSession *session;
@property (nonatomic, copy, readonly) unreadCompletionBlock completionHandler;
@property (nonatomic, copy, readonly) unreadErrorBlock errorHandler;

- (instancetype)initWithSession:(NSURLSession *)session url:(NSURL *)url completion:(unreadCompletionBlock)completion error:(unreadErrorBlock)error;

@end
