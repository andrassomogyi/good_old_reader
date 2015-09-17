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

@implementation ApiManager
#pragma mark - Public fucntions
#pragma mark GET
+ (void)fetchStreamWithCompletion:(void(^)(NSDictionary *))completion withError:(void(^)(NSError *))errorBlock {
    NSURL *url = [EndpointResolver URLForEndpoint:UnreadEndpoint];
    [self queryApiUrl:url withCompletion:^(NSData *data) {
        NSError *jsonError;
        NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        completion(dataDictionary);
    } withError:^(NSError *error, NSInteger statusCode) {
        errorBlock(error);
    }];
}

+ (void)fetchUnreadCountWithCompletion:(void(^)(NSString *))completion withError:(void(^)(NSError *))errorBlock {
    NSURL *url = [EndpointResolver URLForEndpoint:UnreadCountEndpoint];
    [self queryApiUrl:url
             withCompletion:^(NSData *data) {
                 NSError *jsonError;
                 NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                 completion([NSString stringWithFormat:@"%@ unread",dataDictionary[@"max"]]);
             } withError:^(NSError *error, NSInteger statusCode) {
                 errorBlock(error);
             }];
}

+ (void)getTokenWithCompletion:(void(^)(NSData *token))completion withError:(void(^)(NSError *error))errorBlock {
    NSURL *url = [EndpointResolver URLForEndpoint:GetTokenEndpoint];
    [ApiManager queryApiUrl:url withCompletion:^(NSData *data) {
        completion(data);
    } withError:^(NSError *error, NSInteger statusCode) {
        errorBlock(error);
    }];
}

#pragma mark POST
+ (void)markArticleRead:(NSString *)articleId withCompletion:(void(^)(NSData *))completion withError:(void(^)(NSError *))errorBlock {
    NSURL *url = [EndpointResolver URLForEndpoint:MarkAsReadEndpoint];
    NSDictionary *postData = @{@"i": articleId,
                               @"a": @"user/-/state/com.google/read",
                               @"output": @"json"};
    [self postApiUrl:url postData:postData withCompletion:^(NSData *data) {
        completion(data);
    } withError:^(NSError *error, NSInteger statusCode) {
        errorBlock(error);
        ;
    }];
}

+ (void)logoutWithCompletion:(void(^)(NSData *data))completion withError:(void(^)(NSError *error))errorBlock {
    NSURL *url = [EndpointResolver URLForEndpoint:ClientLogoutEndpoint];
    [ApiManager queryApiUrl:url withCompletion:^(NSData *data) {
        completion(data);
    } withError:^(NSError *error, NSInteger statusCode) {
        errorBlock(error);
    }];
}

+ (void)loginUser:(NSString *)username withPassword:(NSString *)password completion:(void(^)(NSData *))completion error:(void(^)(NSError *))errorBlock {
    NSURL *url = [EndpointResolver URLForEndpoint:ClientLoginEndpoint];
    NSDictionary *postData = @{@"client": @"YourAppName",
                               @"accountType": @"HOSTED_OR_GOOGLE",
                               @"service": @"reader",
                               @"Email": username,
                               @"Passwd": password,
                               @"output": @"json"};
    [self postApiUrl:url postData:postData withCompletion:^(NSData *data) {
        completion(data);
    } withError:^(NSError *error, NSInteger statusCode) {
        errorBlock(error);
    }];
}


#pragma mark - Private functions
+ (void)queryApiUrl:(NSURL *)url withCompletion:(void(^)(NSData *))completion withError:(void(^)(NSError *, NSInteger))errorBlock {
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL:url
                                               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                   NSInteger httpStatusCode = [httpResponse statusCode];
                                                   if (error || httpStatusCode != 200) {
                                                       errorBlock(error,httpStatusCode);
                                                   }
                                                   if (httpStatusCode == 200) {
                                                       completion(data);
                                                   }
                                               }];
    [dataTask resume];
}

+ (void)postApiUrl:(NSURL *)url postData:(NSDictionary *)dataDictionary withCompletion:(void(^)(NSData *))completion withError:(void(^)(NSError *, NSInteger))errorBlock {
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession  = [NSURLSession sessionWithConfiguration:config];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    
    for (id key in dataDictionary) {
        id value = dataDictionary[key];
        
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedValue = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString *part = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    
    NSString *bodyString = [parts componentsJoinedByString:@"&"];
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
        if (error || httpStatusCode != 200) {
            errorBlock(error,httpStatusCode);
        }
        if (httpStatusCode == 200) {
            completion(data);
        }
    }];
    
    [task resume];
}

@end
