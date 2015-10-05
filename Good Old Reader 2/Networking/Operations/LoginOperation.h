//
//  LoginOperation.h
//  Good Old Reader 2
//
//  Created by Somogyi András on 05/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "Operation.h"
#import "NSString+UrlEncoding.h"

typedef void(^markAsReadCompletionBlock)(NSData *data);
typedef void(^markAsReadErrorBlock)(NSError *error, NSInteger statusCode);

@interface LoginOperation : Operation

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSURLSession *session;
@property (nonatomic, strong, readonly) NSDictionary *postData;
@property (nonatomic, copy, readonly) markAsReadCompletionBlock completionHandler;
@property (nonatomic, copy, readonly) markAsReadErrorBlock errorHandler;

- (instancetype)initWithSession:(NSURLSession *)session url:(NSURL *)url postData:(NSDictionary *)postData completion:(markAsReadCompletionBlock)completion error:(markAsReadErrorBlock)error;

@end
