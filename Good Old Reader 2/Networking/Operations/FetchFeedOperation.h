//
//  FetchFeedOperation.h
//  Good Old Reader 2
//
//  Created by József Vesza on 02/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "Operation.h"
#import <PersistenceKit/PersistenceKit.h>

typedef void(^feedCompletionBlock)(NSArray *items);
typedef void(^feedErrorBlock)(NSError *error, NSInteger statusCode);

@interface FetchFeedOperation : Operation

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSURLSession *session;
@property (nonatomic, copy, readonly) feedCompletionBlock completionHandler;
@property (nonatomic, copy, readonly) feedErrorBlock errorHandler;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (instancetype)initWithSession:(NSURLSession *)session url:(NSURL *)url completion:(feedCompletionBlock)completion error:(feedErrorBlock)error;

@end
