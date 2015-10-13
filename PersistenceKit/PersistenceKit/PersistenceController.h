    //
//  PersistenceController.h
//  PersistenceKit
//
//  Created by Somogyi András on 13/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^InitCallbackBlock)(void);

@interface PersistenceController : NSObject

@property (strong, readonly) NSManagedObjectContext *managedObjectContext;

- (id)initWithCallback:(InitCallbackBlock)callback;
- (void)save;

@end
