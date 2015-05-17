//
//  InterfaceController.m
//  Good Old Reader 2 WatchKit Extension
//
//  Created by András Somogyi on 2015. 05. 13..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *unreadCount;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *articleTitle;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *originTitle;

@end


@implementation InterfaceController
@synthesize unreadCount;
@synthesize titleLabel;
@synthesize articleTitle;
@synthesize originTitle;


- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.

}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.goodOldReader2"];
    [sharedDefaults synchronize];
    NSString *unreadCountString = [sharedDefaults objectForKey:@"unreadCount"];
    NSString *recentArticle = [sharedDefaults objectForKey:@"recentArticle"];
    NSString *siteName = [sharedDefaults objectForKey:@"siteName"];
    [self.unreadCount setText:[NSString stringWithFormat:@"Unread: %@", unreadCountString.description]];
    [self.titleLabel setText:@"Recent article"];
    [self.articleTitle setText:recentArticle];
    [self.originTitle setText:[NSString stringWithFormat:@"By %@",siteName]];
//    [self.recentArticleLabel setText:[NSString stringWithFormat:@"Recent article:\n\n%@ by\n\n%@",recentArticle, siteName]];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}


- (void) willChangeValueForKey:(NSString *)key {

}

@end



