//
//  Article+CoreDataProperties.h
//  Good Old Reader 2
//
//  Created by Somogyi András on 06/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Article.h"

NS_ASSUME_NONNULL_BEGIN

@interface Article (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *published;
@property (nullable, nonatomic, retain) NSString *canonical;
@property (nullable, nonatomic, retain) NSString *summary_content;
@property (nullable, nonatomic, retain) NSString *author;
@property (nullable, nonatomic, retain) NSString *origin_streamId;
@property (nullable, nonatomic, retain) NSString *origin_title;

@end

NS_ASSUME_NONNULL_END
