//
//  PersistenceManager.m
//  PersistenceKit
//
//  Created by András Somogyi on 18/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import "PersistenceManager.h"
#import <CoreData/CoreData.h>

@implementation PersistenceManager

- (instancetype)initWithCoreDataStack:(CoreDataStack *)coreDataStack
{
    self = [super init];
    if (self) {
        self.managedObjectContext = coreDataStack.managedObjectContext;
    }
    return self;
}
- (void)save:(NSString *)appGroup object:(id)toSave forKey:(NSString *)key {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:appGroup];
    [sharedDefaults setObject:toSave forKey:key];
    [sharedDefaults synchronize];
}

- (id)load:(NSString *)key fromGroup:(NSString *)appGroup {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:appGroup];
    return [sharedDefaults objectForKey:key];
}

- (NSFetchedResultsController*)getFetchedResultsController:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.sortDescriptors = sortDescriptors;
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

- (NSArray *)fetchItemsWithEntityName:(NSString *)entity {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity];
    NSError *error = nil;
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

@end
