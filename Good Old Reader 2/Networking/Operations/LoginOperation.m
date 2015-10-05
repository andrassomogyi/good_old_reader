//
//  LoginOperation.m
//  Good Old Reader 2
//
//  Created by Somogyi András on 05/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "LoginOperation.h"

@interface LoginOperation ()

@property (nonatomic, strong, readwrite) NSURL *url;
@property (nonatomic, strong, readwrite) NSURLSession *session;
@property (nonatomic, strong, readwrite) NSDictionary *postData;
@property (nonatomic, copy, readwrite) markAsReadCompletionBlock completionHandler;
@property (nonatomic, copy, readwrite) markAsReadErrorBlock errorHandler;

@end

@implementation LoginOperation

- (instancetype)initWithSession:(NSURLSession *)session url:(NSURL *)url postData:(NSDictionary *)postData completion:(markAsReadCompletionBlock)completion error:(markAsReadErrorBlock)error
{
    self = [super init];
    if (self) {
        self.session = session != nil ? session : [NSURLSession sharedSession];
        self.url = url;
        self.postData = postData;
        self.completionHandler = completion;
        self.errorHandler = error;
    }
    return self;
}

- (void)execute {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.url];
    NSString *bodyString = [NSString encodeUrl:self.postData];
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    request.HTTPMethod = @"POST";
    request.HTTPBody = bodyData;
    
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSInteger httpStatusCode = [httpResponse statusCode];
        
        [super finish];
        
        if ( (error || [(NSHTTPURLResponse *)response statusCode] == 403) && self.errorHandler) {
            self.errorHandler(error, httpStatusCode);
        }
        else if (self.completionHandler) {
            self.completionHandler(data);
        }
    }];
    
    [task resume];
}

@end
