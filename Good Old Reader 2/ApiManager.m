//
//  ApiManager.m
//  Good Old Reader 2
//
//  Created by András Somogyi on 14/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import "ApiManager.h"

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
    config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json; charset=utf-8"};
    NSURLSession *urlSession  = [NSURLSession sessionWithConfiguration:config];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDictionary options:kNilOptions error:&error];
    NSURLSessionUploadTask *uploadTask = [urlSession uploadTaskWithRequest:request fromData:data
                                                         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                             NSInteger httpStatusCode = [httpResponse statusCode];
                                                             if (error) {
                                                                 errorBlock(error,httpStatusCode);
                                                             }
                                                             if (httpStatusCode == 200) {
                                                                 completion(data);
                                                             }
                                                         }];
    [uploadTask resume];
}
@end
