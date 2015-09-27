//
//  AutoHeightTableViewCell.h
//  Good Old Reader 2
//
//  Created by András Somogyi on 18/09/15.
//  Copyright (c) 2015 András Somogyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoHeightTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellSiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellPublishedLabel;

@end
