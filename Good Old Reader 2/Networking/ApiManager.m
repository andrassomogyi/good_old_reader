//
//  ApiManager.m
//  Good Old Reader 2
//
//  Created by András Somogyi on 14/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApiManager.h"
#import "EndpointResolver.h"
#import "NSString+UrlEncoding.h"
#import <PersistenceKit/PersistenceKit.h>
#import "Article.h"
#import "AppDelegate.h"
#import "FetchFeedOperation.h"
#import "FetchUnreadOperation.h"
#import "FeedTableViewData.h"
#import "GetTokenOperation.h"

@interface ApiManager ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation ApiManager

- (NSOperationQueue *)operationQueue {
    
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    
    return _operationQueue;
}

#pragma mark - Public functions

#pragma mark GET

- (void)fetchStreamWithCompletion:(nullable void(^)(FeedTableViewData *viewData))completion withError:(nullable void(^)(NSError *error))errorBlock {
    
    __block NSArray *feedItems = [[NSArray alloc] init];
    
    FetchFeedOperation *feedOperation = [[FetchFeedOperation alloc] initWithSession:nil url:[EndpointResolver URLForEndpoint:UnreadEndpoint] completion:^(NSArray *items) {
        feedItems = items;
    } error:^(NSError *error, NSInteger statusCode) {
        
    }];
    
    FetchUnreadOperation *countOperation = [[FetchUnreadOperation alloc] initWithSession:nil url:[EndpointResolver URLForEndpoint:UnreadCountEndpoint] completion:^(NSString *count) {
        
        FeedTableViewData *viewData = [[FeedTableViewData alloc] initWithArticles:feedItems title:count];
        if (completion) {
            completion(viewData);
        }
        
    } error:^(NSError *error, NSInteger statusCode) {
        
    }];
    
    [countOperation addDependency:feedOperation];
    
    self.operationQueue.suspended = YES;
    
    [self.operationQueue addOperation:feedOperation];
    [self.operationQueue addOperation:countOperation];
    
    self.operationQueue.suspended = NO;
    
}

- (void)getTokenWithCompletion:(void(^)(NSData *token))completion withError:(void(^)(NSError *error))errorBlock {
    
    GetTokenOperation *operation = [[GetTokenOperation alloc] initWithSession:nil url:[EndpointResolver URLForEndpoint:GetTokenEndpoint] completion:^(NSData *token) {
        if (completion) {
            completion(token);
        }
    } error:^(NSError *error, NSInteger statusCode) {
        
    }];
    
    self.operationQueue.suspended = YES;
    
    [self.operationQueue addOperation:operation];
    
    self.operationQueue.suspended = NO;
}

#pragma mark POST
- (void)markArticleRead:(NSString *)articleId withCompletion:(void(^)(NSData *))completion withError:(void(^)(NSError *))errorBlock {
    NSURL *url = [EndpointResolver URLForEndpoint:MarkAsReadEndpoint];
    NSDictionary *postData = @{@"i": articleId,
                               @"a": @"user/-/state/com.google/read",
                               @"output": @"json"};
    [self postApiUrl:url postData:postData withCompletion:^(NSData *data) {
        if (completion) {
            completion(data);
        }
    } withError:^(NSError *error, NSInteger statusCode) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)logoutWithCompletion:(void(^)(NSData *data))completion withError:(void(^)(NSError *error))errorBlock {
    NSURL *url = [EndpointResolver URLForEndpoint:ClientLogoutEndpoint];
    [self queryApiUrl:url withCompletion:^(NSData *data) {
        if (completion) {
            completion(data);
        }
    } withError:^(NSError *error, NSInteger statusCode) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)loginUser:(NSString *)username withPassword:(NSString *)password completion:(void(^)(NSData *))completion error:(void(^)(NSError *))errorBlock {
    NSURL *url = [EndpointResolver URLForEndpoint:ClientLoginEndpoint];
    NSDictionary *postData = @{@"client": @"YourAppName",
                               @"accountType": @"HOSTED_OR_GOOGLE",
                               @"service": @"reader",
                               @"Email": username,
                               @"Passwd": password,
                               @"output": @"json"};
    [self postApiUrl:url postData:postData withCompletion:^(NSData *data) {
        if (completion) {
            completion(data);
        }
    } withError:^(NSError *error, NSInteger statusCode) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}


#pragma mark - Private functions
- (void)queryApiUrl:(NSURL *)url withCompletion:(void(^)(NSData *))completion withError:(void(^)(NSError *, NSInteger))errorBlock {
    
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSInteger httpStatusCode = [httpResponse statusCode];
        if (!error && completion && (httpStatusCode == 200 || httpStatusCode == 204)) {
            completion(data);
        } else if (errorBlock) {
            errorBlock(error, httpStatusCode);
        }
    }];
    
    [dataTask resume];
}

- (void)postApiUrl:(NSURL *)url postData:(NSDictionary *)dataDictionary withCompletion:(void(^)(NSData *))completion withError:(void(^)(NSError *, NSInteger))errorBlock {
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession  = [NSURLSession sessionWithConfiguration:config];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSString *bodyString = [NSString encodeUrl:dataDictionary];
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    request.HTTPMethod = @"POST";
    request.HTTPBody = bodyData;
    
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSString *userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
    
    [request addValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [request addValue:@"en;q=1, fr;q=0.9, de;q=0.8, zh-Hans;q=0.7, zh-Hant;q=0.6, ja;q=0.5" forHTTPHeaderField:@"Accept-Language"];
    
//    NSLog(@"Request: %@", [request allHTTPHeaderFields]);
    
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSLog(@"Response: %@", response);
//        NSLog(@"Error: %@", error);
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSInteger httpStatusCode = [httpResponse statusCode];
        if (error && errorBlock) {
            errorBlock(error,httpStatusCode);
        }
        else if (completion) {
            completion(data);
        }
    }];
    
    [task resume];
}

- (void)queryApiUrlInBackground:(NSURL *)url {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"edu.andrassomogyi.Good-Old-Reader-2"];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask *dataTask = [urlSession downloadTaskWithURL:url];
    [dataTask resume];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite * 100;
    
    NSLog(@"%.1f%%", progress);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"Download finished to location: %@", location);
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    void (^completionBlock)() = appDelegate.backgroundSessionCompletionHandler;
    appDelegate.backgroundSessionCompletionHandler = nil;
    if (completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock();
        });
    }
}

@end
