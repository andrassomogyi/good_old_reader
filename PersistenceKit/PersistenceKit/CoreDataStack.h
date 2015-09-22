//
//  CoreDataStack.h
//  PersistenceKit
//
//  Created by András Somogyi on 21/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataStack : NSObject

- (id)initWithStoreURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL;

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

@end
