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

#import "MapViewController.h"

@interface AppDelegate () <CDEPersistentStoreEnsembleDelegate>
@end

@implementation AppDelegate {
    CDEICloudFileSystem *_cloudFileSystem;
    CDEPersistentStoreEnsemble *_ensemble;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupMagicalRecord];
    [self setupEnsembles];
    
    [self setAppearances];
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.rootViewController = [MapViewController new];
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

#pragma mark - Appearances

- (void)setAppearances {
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
}

- (NSArray *)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble globalIdentifiersForManagedObjects:(NSArray *)objects {
    return [objects valueForKeyPath:@"uniqueIdentifier"];
}

@end
