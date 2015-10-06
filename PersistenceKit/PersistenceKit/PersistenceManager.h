//
//  PersistenceManager.h
//  PersistenceKit
//
//  Created by András Somogyi on 18/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersistenceKit.h"

@interface PersistenceManager : NSObject

@property (nonatomic, strong) CoreDataStack *coreDataStack;

- (instancetype)initWithCoreDataStack:(CoreDataStack *)coreDataStack;
- (void)save:(NSString *)appGroup object:(id)toSave forKey:(NSString *)key;
- (id)load:(NSString *)key fromGroup:(NSString *)appGroup;

- (NSFetchedResultsController*)getFetchedResultsController:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors;
- (NSArray *)fetchItemsWithEntityName:(NSString *)entity;

@end
