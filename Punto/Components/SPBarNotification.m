//
//  SPBarNotification.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 21/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "SPBarNotification.h"

@implementation SPBarNotification

#pragma mark - Initialization

+ (id)sharedInstance {
    static SPBarNotification *_barNotificationSharedInstance = nil;
    static dispatch_once_t onceBarNotificationToken;
    dispatch_once(&onceBarNotificationToken, ^{
        _barNotificationSharedInstance = [SPBarNotification new];
    });
    return _barNotificationSharedInstance;
}

- (id)init {
    if (!(self = [super init])) return nil;
    
    self.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    self.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    self.notificationLabelBackgroundColor = [UIColor redColor];
    
    return self;
}

@end
