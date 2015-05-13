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

@end


@implementation InterfaceController
@synthesize unreadCount;

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
    [self.unreadCount setText:[NSString stringWithFormat:@"Unread: %@", unreadCountString.description]];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}


- (void) willChangeValueForKey:(NSString *)key {

}

@end



