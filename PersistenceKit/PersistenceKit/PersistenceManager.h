//
//  PersistenceManager.h
//  PersistenceKit
//
//  Created by András Somogyi on 18/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersistenceManager : NSObject

+ (void)save:(id)toSave forKey:(NSString *)key;
+ (void)save:(NSString *)appGroup object:(id)toSave forKey:(NSString *)key;
+ (id)load:(NSString *)key;
+ (id)load:(NSString *)key fromGroup:(NSString *)appGroup;

@end
