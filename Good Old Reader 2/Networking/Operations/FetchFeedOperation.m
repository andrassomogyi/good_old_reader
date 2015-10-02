//
//  FetchFeedOperation.m
//  Good Old Reader 2
//
//  Created by József Vesza on 02/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "FetchFeedOperation.h"
#import "Article.h"

@interface FetchFeedOperation ()

@property (nonatomic, strong, readwrite) NSURL *url;
@property (nonatomic, strong, readwrite) NSURLSession *session;
@property (nonatomic, copy, readwrite) feedCompletionBlock completionHandler;
@property (nonatomic, copy, readwrite) feedErrorBlock errorHandler;

@end

@implementation FetchFeedOperation

- (instancetype)initWithSession:(NSURLSession *)session url:(NSURL *)url completion:(feedCompletionBlock)completion error:(feedErrorBlock)error
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

- (NSArray *)parseData:(NSData *)data {
    
    NSError *jsonError;
    NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
    
    dataDictionary = dataDictionary[@"items"];
    
    NSMutableArray *articles = [[NSMutableArray alloc] init];
    
    for (NSDictionary *item in dataDictionary) {
        
        NSDictionary *articleItem = @{
                                      @"articleId" : [item objectForKey:@"id"],
                                      @"title" : [item objectForKey:@"title"],
                                      @"published": item[@"published"],
                                      @"canonical": [[[item objectForKey:@"canonical"] objectAtIndex:0] objectForKey:@"href"],
                                      @"summary_content" : [[item objectForKey:@"summary"] objectForKey:@"content"],
                                      @"author" : [item objectForKey:@"author"],
                                      @"origin_streamId" : [[item objectForKey:@"origin"] objectForKey:@"streamId"],
                                      @"origin_title" : [[item objectForKey:@"origin"] objectForKey:@"title"]};
        
        Article *article = [[Article alloc] initWithDictionary:articleItem];
        
        if (article) {
            [articles addObject:article];
        }
    }
    
    return articles;
}

@end