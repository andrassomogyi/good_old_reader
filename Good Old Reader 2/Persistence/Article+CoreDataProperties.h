//
//  Article+CoreDataProperties.h
//  Good Old Reader 2
//
//  Created by Somogyi András on 07/10/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Article.h"

NS_ASSUME_NONNULL_BEGIN

@interface Article (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *articleId;
@property (nullable, nonatomic, retain) NSString *author;
@property (nullable, nonatomic, retain) NSString *canonical;
@property (nullable, nonatomic, retain) NSString *originStreamId;
@property (nullable, nonatomic, retain) NSString *originTitle;
@property (nullable, nonatomic, retain) NSNumber *published;
@property (nullable, nonatomic, retain) NSString *summaryContent;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic) NSNumber *markedAsRead;

@end

NS_ASSUME_NONNULL_END
