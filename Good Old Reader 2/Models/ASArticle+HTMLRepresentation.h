//
//  Article+HTMLRepresentation.h
//  Good Old Reader 2
//
//  Created by Somogyi András on 25/09/15.
//  Copyright © 2015 András Somogyi. All rights reserved.
//

#import "ASArticle.h"

@interface ASArticle (HTMLRepresentation)

+ (NSString *) HTMLRepresentation:(ASArticle *)article;

@end
