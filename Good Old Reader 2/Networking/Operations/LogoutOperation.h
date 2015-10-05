//
//  LogoutOperation.h
//  Good Old Reader 2
//
//  Created by Somogyi András on 05/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "Operation.h"

typedef void(^logoutCompletionBlock)(NSData *data);
typedef void(^logoutErrorBlock)(NSError *error, NSInteger statusCode);

@interface LogoutOperation : Operation

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSURLSession *session;
@property (nonatomic, copy, readonly) logoutCompletionBlock completionHandler;
@property (nonatomic, copy, readonly) logoutErrorBlock errorHandler;

- (instancetype)initWithSession:(NSURLSession *)session url:(NSURL *)url completion:(logoutCompletionBlock)completion error:(logoutErrorBlock)error;

@end
