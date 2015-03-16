//
//  Http.m
//  Good Old Reader
//
//  Created by Somogyi András on 05/11/13.
//  Copyright (c) 2013 András Somogyi. All rights reserved.
//

#import "Http.h"

@implementation Http

@synthesize dataReady;
@synthesize networkError; // TODO: implement network error notification

- (id) initWithUrlPost:(NSString*)url
              postData:(NSString*)post {
    if (self = [super init]) {
        [self setDataReady:NO]; // Indicator variable for received data
        
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        
        NSMutableURLRequest *Request = [[NSMutableURLRequest alloc]init];
        [Request setURL:[NSURL URLWithString:url]];
        [Request setHTTPMethod:@"POST"];
        [Request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [Request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [Request setHTTPBody:postData];
        
        NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:Request delegate:self];
        
        if (theConnection) {
            self.receivedData = [NSMutableData data];
        }
        return self;
    }
    else return nil;
}

- (id) initWithUrlGet:(NSString*)url {
    if (self = [super init]) {
        [self setDataReady:NO]; // Indicator variable for received data
        
        NSMutableURLRequest *Request = [[NSMutableURLRequest alloc]init];
        [Request setURL:[NSURL URLWithString:url]];
        [Request setHTTPMethod:@"GET"];
        [Request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:Request delegate:self];
        
        if (theConnection) {
            self.receivedData = [NSMutableData data];
        }
        return self;
    }
    else return nil;
}

#pragma mark - HTTP communication
- (void)connection: (NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_receivedData setLength:0];
}

- (void)connection: (NSURLConnection *) connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
}

- (void)connection: (NSURLConnection *) connection didFailWithError:(NSError *)error {
    NSLog(@"Connection FAILED! ERROR %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [self setNetworkError:[error localizedDescription]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *) connection {
    NSLog(@"Success! Received %lu bytes of data. (Requesting object: %@)",
          (unsigned long)[_receivedData length],
          [self class]);
    [self setDataReady:YES];
}



@end
