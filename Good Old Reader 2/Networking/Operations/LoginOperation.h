//
//  LoginOperation.h
//  Good Old Reader 2
//
//  Created by Somogyi András on 05/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "Operation.h"
#import "NSString+UrlEncoding.h"

typedef void(^loginCompletionBlock)(NSData *data);
typedef void(^loginErrorBlock)(NSError *error, NSInteger statusCode);

@interface LoginOperation : Operation

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSURLSession *session;
@property (nonatomic, strong, readonly) NSDictionary *postData;
@property (nonatomic, copy, readonly) loginCompletionBlock completionHandler;
@property (nonatomic, copy, readonly) loginErrorBlock errorHandler;

- (instancetype)initWithSession:(NSURLSession *)session url:(NSURL *)url postData:(NSDictionary *)postData completion:(loginCompletionBlock)completion error:(loginErrorBlock)error;

@end
