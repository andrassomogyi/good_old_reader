//
//  Operation.m
//  Good Old Reader 2
//
//  Created by József Vesza on 02/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "Operation.h"

@interface Operation ()

@property (nonatomic) BOOL pExecuting;
@property (nonatomic) BOOL pFinished;

@end

@implementation Operation

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isExecuting {
    return self.pExecuting;
}

- (BOOL)isFinished {
    return self.pFinished;
}

- (void)setPExecuting:(BOOL)pExecuting {
    [self willChangeValueForKey:@"isExecuting"];
    _pExecuting = pExecuting;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setPFinished:(BOOL)pFinished {
    [self willChangeValueForKey:@"isFinished"];
    _pFinished = pFinished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)start {
    self.pExecuting = YES;
    [self execute];
}

- (void)execute {
    NSAssert(NO, @"Subclasses must implement this method.");
}

- (void)finish {
    self.pExecuting = NO;
    self.pFinished = YES;
}

@end