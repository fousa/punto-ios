//
//  AppDelegate.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "AppDelegate.h"

#import "MapViewController.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"Punto"];
    
    [self setAppearances];
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _window.rootViewController = [MapViewController new];
    [_window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [MagicalRecord cleanUp];
}

#pragma mark - Appearances

- (void)setAppearances {
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-1000, -1000) forBarMetrics:UIBarMetricsDefault];
}

@end
