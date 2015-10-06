//
//  Article.h
//  Good Old Reader 2
//
//  Created by Somogyi András on 06/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ASArticle.h"

NS_ASSUME_NONNULL_BEGIN

@interface Article : NSManagedObject

+ (instancetype)insertArticle:(ASArticle *)article inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSString*)entityName;

@end

NS_ASSUME_NONNULL_END

#import "Article+CoreDataProperties.h"
