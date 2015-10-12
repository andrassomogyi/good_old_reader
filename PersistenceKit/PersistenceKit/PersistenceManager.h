//
//  PersistenceManager.h
//  PersistenceKit
//
//  Created by András Somogyi on 18/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersistenceKit.h"

@class CoreDataStack;
@class NSFetchedResultsController;

@interface PersistenceManager : NSObject

NS_ASSUME_NONNULL_BEGIN

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (instancetype)initWithCoreDataStack:(CoreDataStack *)coreDataStack;
- (void)save:(NSString *)appGroup object:(id)toSave forKey:(NSString *)key;
- (id)load:(NSString *)key fromGroup:(NSString *)appGroup;

- (NSFetchedResultsController *)getFetchedResultsController:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors;
- (NSArray *)fetchItemsWithEntityName:(NSString *)entity withPredicate:(nullable NSPredicate *)predicate withSortDescriptor:(nullable NSArray *)sortDescriptors;

NS_ASSUME_NONNULL_END

@end
