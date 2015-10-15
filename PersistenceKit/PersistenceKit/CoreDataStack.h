//
//  CoreDataStack.h
//  PersistenceKit
//
//  Created by András Somogyi on 21/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^InitCallbackBlock)(void);

@interface CoreDataStack : NSObject

@property (strong, readonly) NSManagedObjectContext *managedObjectContext;

- (id)initWithStoreURL:(NSURL*)storeURL modelURL:(NSURL*)modelURL withCallback:(InitCallbackBlock)callback;
- (void)save;

@end
