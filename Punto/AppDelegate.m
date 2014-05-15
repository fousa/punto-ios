//
//  AppDelegate.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import <MagicalRecord/CoreData+MagicalRecord.h>
#import <Ensembles/Ensembles.h>

#import "AppDelegate.h"

#import "SPClient.h"

#import "Feed.h"

#import "MapViewController.h"
#import "FeedsTableViewController.h"

#import "SPBarNotification.h"

@interface AppDelegate () <CDEPersistentStoreEnsembleDelegate>
@end

@implementation AppDelegate {
    CDEICloudFileSystem *_cloudFileSystem;
    CDEPersistentStoreEnsemble *_ensemble;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    [self setupMagicalRecord];
    [self setupEnsembles];
    
    [self setAppearances];
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[FeedsTableViewController new]];
    _window.rootViewController = navigationController;
    [_window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [MagicalRecord cleanUp];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    UIBackgroundTaskIdentifier identifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        [self syncWithCompletion:^{
            [[UIApplication sharedApplication] endBackgroundTask:identifier];
        }];
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    UINavigationController *controller = (UINavigationController *)_window.rootViewController;
    if ([controller.topViewController isKindOfClass:[MapViewController class]]) {
        [((MapViewController *)controller.topViewController) performFetch];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSString *identifier = notification.userInfo[kSpotUniqueIdentifier];
    if (IsEmpty(identifier)) return;
    
    Feed *feed = [Feed MR_findFirstByAttribute:@"uniqueIdentifier" withValue:identifier];
    if (IsEmpty(feed)) return;
    
    UINavigationController *controller = (UINavigationController *)_window.rootViewController;
    if ([controller.topViewController isKindOfClass:[MapViewController class]]) {
        ((MapViewController *)controller.topViewController).feed = feed;
        [((MapViewController *)controller.topViewController) processFeed];
    } else if ([controller.topViewController isKindOfClass:[FeedsTableViewController class]]) {
        [((FeedsTableViewController *)controller.topViewController) presentMapController:feed];
    }
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    dispatch_group_t group = dispatch_group_create();
    
    NSArray *feeds = [Feed MR_findByAttribute:@"notify" withValue:@(YES)];
    for (Feed *feed in feeds) {
        dispatch_group_enter(group);
        [SPClient fetchMessagesForFeed:feed completion:^(NSError *error, NSArray *messages) {
            BOOL shouldProcess = [feed processMessages:messages];
            if (shouldProcess) {
                UILocalNotification *localNotification = [UILocalNotification new];
                localNotification.fireDate = [NSDate date];
                localNotification.timeZone = [NSTimeZone systemTimeZone];
                localNotification.alertAction = NSLocalizedString(@"Show", @"Show");
                localNotification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"We noticed some movement in the '%@' feed.", @"We noticed some movement in the '%@' feed."), feed.name];
                localNotification.userInfo = @{ kSpotUniqueIdentifier : feed.uniqueIdentifier };
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            }
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        completionHandler(feeds.count > 0 ? UIBackgroundFetchResultNewData : UIBackgroundFetchResultNoData);
    });
}

#pragma mark - Appearances

- (void)setAppearances {
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.373 green:0.396 blue:0.451 alpha:1.000]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithWhite:0.925 alpha:1.000]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f] }];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:16.0f] } forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-1000, -1000) forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - Core Data

- (void)setupMagicalRecord {
    NSManagedObjectModel *model = [NSManagedObjectModel MR_newManagedObjectModelNamed:@"Punto.momd"];
    [NSManagedObjectModel MR_setDefaultManagedObjectModel:model];
    [MagicalRecord setShouldAutoCreateManagedObjectModel:NO];
    [MagicalRecord setupAutoMigratingCoreDataStack];
}

#pragma mark - Ensembles

- (void)setupEnsembles {
    _cloudFileSystem = [[CDEICloudFileSystem alloc] initWithUbiquityContainerIdentifier:kUbiquityContainerIdentifier];
    NSURL *objectModelURL = [[NSBundle mainBundle] URLForResource:@"Punto" withExtension:@"momd"];
    _ensemble = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:@"Punto" persistentStoreURL:[NSPersistentStore MR_urlForStoreName:[MagicalRecord defaultStoreName]] managedObjectModelURL:objectModelURL cloudFileSystem:_cloudFileSystem];
    _ensemble.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localSaveOccurred:) name:CDEMonitoredManagedObjectContextDidSaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudDataDidDownload:) name:CDEICloudFileSystemDidDownloadFilesNotification object:nil];

    [self syncWithCompletion:nil];
}

- (void)localSaveOccurred:(NSNotification *)notification {
    [self syncWithCompletion:nil];
}

- (void)cloudDataDidDownload:(NSNotification *)notification {
    [self syncWithCompletion:nil];
}

- (void)syncWithCompletion:(void(^)(void))completion {
    if (_ensemble.isMerging) return;
    
    dispatch_async_main(^{
        if (_ensemble.isLeeched) {
            [_ensemble mergeWithCompletion:^(NSError *error) {
                if (error) NSLog(@"Error in merge: %@", error);
                if (completion) completion();
            }];
        } else {
            [_ensemble leechPersistentStoreWithCompletion:^(NSError *error) {
                if (error) NSLog(@"Error in leech: %@", error);
                if (completion) completion();
            }];
        }
    });
}

- (void)persistentStoreEnsembleWillImportStore:(CDEPersistentStoreEnsemble *)ensemble {
    [[SPBarNotification sharedInstance] displayNotificationWithMessage:@"Importing data" completion:nil];
}

- (void)persistentStoreEnsembleDidImportStore:(CDEPersistentStoreEnsemble *)ensemble {
    [[SPBarNotification sharedInstance] dismissNotification];
}

- (BOOL)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble shouldSaveMergedChangesInManagedObjectContext:(NSManagedObjectContext *)savingContext reparationManagedObjectContext:(NSManagedObjectContext *)reparationContext {
    dispatch_async_main(^{
        [[SPBarNotification sharedInstance] displayNotificationWithMessage:@"Syncing data" completion:nil];
    });
    return YES;
}

- (void)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble didSaveMergeChangesWithNotification:(NSNotification *)notification {
    NSManagedObjectContext *rootContext = [NSManagedObjectContext MR_rootSavingContext];
    [rootContext performBlockAndWait:^{
        [rootContext mergeChangesFromContextDidSaveNotification:notification];
    }];
    
    NSManagedObjectContext *mainContext = [NSManagedObjectContext MR_defaultContext];
    [mainContext performBlockAndWait:^{
        [mainContext mergeChangesFromContextDidSaveNotification:notification];
    }];
    
    dispatch_async_main(^{
        [[SPBarNotification sharedInstance] dismissNotification];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDataChangedNotification object:nil];
    });
}

- (NSArray *)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble globalIdentifiersForManagedObjects:(NSArray *)objects {
    return [objects valueForKeyPath:@"uniqueIdentifier"];
}

@end
