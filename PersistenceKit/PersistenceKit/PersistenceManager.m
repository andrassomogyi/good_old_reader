//
//  PersistenceManager.m
//  PersistenceKit
//
//  Created by András Somogyi on 18/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import "PersistenceManager.h"

@implementation PersistenceManager

+ (void)save:(id)toSave forKey:(NSString *)key {
    NSUserDefaults *sharedDefaults = [NSUserDefaults standardUserDefaults];;
    [sharedDefaults setObject:toSave forKey:key];
    [sharedDefaults synchronize];
}

+ (void)save:(NSString *)appGroup object:(id)toSave forKey:(NSString *)key {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:appGroup];
    [sharedDefaults setObject:toSave forKey:key];
    [sharedDefaults synchronize];
}

+ (id)load:(NSString *)key {
    NSUserDefaults *sharedDefaults = [NSUserDefaults standardUserDefaults];;
    return [sharedDefaults objectForKey:key];
}

+ (id)load:(NSString *)key fromGroup:(NSString *)appGroup {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:appGroup];
    return [sharedDefaults objectForKey:key];
}

@end
