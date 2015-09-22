//
//  CoreDataStack.m
//  PersistenceKit
//
//  Created by András Somogyi on 21/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import "CoreDataStack.h"
#import <CoreData/CoreData.h>

@interface CoreDataStack()

@property (nonatomic,strong) NSURL* modelURL;
@property (nonatomic,strong) NSURL* storeURL;

@end

@implementation CoreDataStack

- (id)initWithStoreURL:(NSURL*)storeURL modelURL:(NSURL*)modelURL
{
    self = [super init];
    if (self) {
        self.storeURL = storeURL;
        self.modelURL = modelURL;
        [self setupManagedObjectContext];
    }
    return self;
}

- (void)setupManagedObjectContext
{
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    NSError* error;
    
    [self.managedObjectContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:nil error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    }
    self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
}

- (NSManagedObjectModel*)managedObjectModel
{
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
}

@end
