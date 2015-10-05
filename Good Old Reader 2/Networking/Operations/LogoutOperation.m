//
//  LogoutOperation.m
//  Good Old Reader 2
//
//  Created by Somogyi András on 05/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "LogoutOperation.h"

@interface LogoutOperation ()

@property (nonatomic, strong, readwrite) NSURL *url;
@property (nonatomic, strong, readwrite) NSURLSession *session;
@property (nonatomic, copy, readwrite) logoutCompletionBlock completionHandler;
@property (nonatomic, copy, readwrite) logoutErrorBlock errorHandler;

@end

@implementation LogoutOperation

- (instancetype)initWithSession:(NSURLSession *)session url:(NSURL *)url completion:(logoutCompletionBlock)completion error:(logoutErrorBlock)error
{
    self = [super init];
    if (self) {
        self.session = session != nil ? session : [NSURLSession sharedSession];
        self.url = url;
        self.completionHandler = completion;
        self.errorHandler = error;
    }
    return self;
}

- (void)execute {
    
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:self.url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger httpStatusCode = [httpResponse statusCode];
        
        [super finish];
        
        if (!error && self.completionHandler && (httpStatusCode == 200 || httpStatusCode == 204)) {
            
            self.completionHandler(data);
            
        } else if (self.errorHandler) {
            
            self.errorHandler(error, httpStatusCode);
        }
    }];
    
    [task resume];
}

@end
