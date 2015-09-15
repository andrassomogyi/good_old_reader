//
//  ApiManager.m
//  Good Old Reader 2
//
//  Created by András Somogyi on 14/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import "ApiManager.h"
#import <UIKit/UIKit.h>

@implementation ApiManager

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
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDictionary options:kNilOptions error:&error];
    
    request.HTTPMethod = @"POST";
    request.HTTPBody = data;
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"utf-8" forHTTPHeaderField:@"charset"];
    
    NSString *userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
    
    [request addValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [request addValue:@"en;q=1, fr;q=0.9, de;q=0.8, zh-Hans;q=0.7, zh-Hant;q=0.6, ja;q=0.5" forHTTPHeaderField:@"Accept-Language"];
    
//    NSLog(@"Request: %@", [request allHTTPHeaderFields]);
    
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSLog(@"Response: %@", response);
//        NSLog(@"Error: %@", error);
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSInteger httpStatusCode = [httpResponse statusCode];
        if (error) {
            errorBlock(error,httpStatusCode);
        }
        if (httpStatusCode == 200) {
            completion(data);
        }
    }];
    
    [task resume];
}
@end
