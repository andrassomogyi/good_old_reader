//
//  FetchUnreadOperation.m
//  Good Old Reader 2
//
//  Created by József Vesza on 02/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "FetchUnreadOperation.h"

@interface FetchUnreadOperation ()

@property (nonatomic, strong, readwrite) NSURL *url;
@property (nonatomic, strong, readwrite) NSURLSession *session;
@property (nonatomic, copy, readwrite) unreadCompletionBlock completionHandler;
@property (nonatomic, copy, readwrite) unreadErrorBlock errorHandler;

@end

@implementation FetchUnreadOperation

- (instancetype)initWithSession:(NSURLSession *)session url:(NSURL *)url completion:(unreadCompletionBlock)completion error:(unreadErrorBlock)error
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
            
            self.completionHandler([self parseData:data]);
            
        } else if (self.errorHandler) {
            
            self.errorHandler(error, httpStatusCode);
        }
    }];
    
    [task resume];
}

- (NSString *)parseData:(NSData *)data {
    
    NSError *jsonError;
    NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
    
    NSString *unread = [NSString stringWithFormat:@"%@",dataDictionary[@"max"]];
    
    return unread;
}

@end
