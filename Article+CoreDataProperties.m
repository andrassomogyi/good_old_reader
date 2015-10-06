//
//  Article+CoreDataProperties.m
//  Good Old Reader 2
//
//  Created by Somogyi András on 06/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Article+CoreDataProperties.h"

@implementation Article (CoreDataProperties)

@dynamic title;
@dynamic published;
@dynamic canonical;
@dynamic summary_content;
@dynamic author;
@dynamic origin_streamId;
@dynamic origin_title;

@end
