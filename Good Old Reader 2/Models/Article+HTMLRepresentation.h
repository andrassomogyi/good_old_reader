//
//  Article+HTMLRepresentation.h
//  Good Old Reader 2
//
//  Created by Somogyi András on 25/09/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "Article.h"

@interface Article (HTMLRepresentation)

+ (NSString *) HTMLRepresentation:(Article *)article;

@end
