//
//  QRreaderViewController.h
//  Good Old Reader 2
//
//  Created by András Somogyi on 2015. 05. 26..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRreaderViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property NSDictionary *articleUrlDict;
@end
