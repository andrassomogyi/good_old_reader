//
//  GetTokenOperation.h
//  Good Old Reader 2
//
//  Created by József Vesza on 02/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "Operation.h"

typedef void(^tokenCompletionBlock)(NSData *token);
typedef void(^tokenErrorBlock)(NSError *error, NSInteger statusCode);

@interface GetTokenOperation : Operation

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSURLSession *session;
@property (nonatomic, copy, readonly) tokenCompletionBlock completionHandler;
@property (nonatomic, copy, readonly) tokenErrorBlock errorHandler;

- (instancetype)initWithSession:(NSURLSession *)session url:(NSURL *)url completion:(tokenCompletionBlock)completion error:(tokenErrorBlock)error;


@end
