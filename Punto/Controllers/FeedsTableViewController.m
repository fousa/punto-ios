//
//  FeedsTableViewController.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "FeedsTableViewController.h"
#import "FeedTableViewController.h"
#import "MapViewController.h"

#import "Feed.h"

#import "FeedCollectionViewCell.h"

@interface FeedsTableViewController ()
@end

@implementation FeedsTableViewController {
    NSMutableArray *_feeds;
}

#pragma mark - View

+ (id)new {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    
    CGFloat padding = 0;
    if (IsIPad()) {
        padding = 20.0f;
        CGFloat side = (punto.window.bounds.size.height - (padding * 6)) / 5;
        layout.itemSize = CGSizeMake(side, side);
    } else {
        padding = 10.0f;
        CGFloat side = (punto.window.bounds.size.width - (padding * 5)) / 4;
        layout.itemSize = CGSizeMake(side, side);
    }
    
    layout.minimumInteritemSpacing = padding;
    layout.minimumLineSpacing = padding;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(padding, padding, padding, padding);
    
    
    return [[self alloc] initWithCollectionViewLayout:layout];
}

+ (CGSize)deviceItemSize {
    return CGSizeMake(0, 0);
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[FeedCollectionViewCell class] forCellWithReuseIdentifier:@"FeedCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataChanged:) name:kDataChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"My Spots", @"My Spots");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDataChangedNotification object:nil];
}

#pragma mark - Layout

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Notifications

- (void)dataChanged:(NSNotification *)notification {
    _feeds = [Feed MR_findAllSortedBy:@"name" ascending:YES].mutableCopy;
    [self.collectionView reloadData];
}

#pragma mark - Feed

- (void)presentFeedController:(Feed *)feed {
    FeedTableViewController *feedController = [FeedTableViewController new];
    feedController.feed = feed;
    if (feed) {
        [self.navigationController pushViewController:feedController animated:YES];
    } else {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:feedController];
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

- (void)presentMapController:(Feed *)feed {
    MapViewController *controller = [MapViewController new];
    controller.feed = feed;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _feeds.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FeedCollectionViewCell *cell = (FeedCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FeedCell" forIndexPath:indexPath];
    
    if (indexPath.row == _feeds.count) {
        [cell setLabelText:@"+"];
    } else {
        Feed *feed = _feeds[indexPath.row];
        [cell setLabelText:feed.name];
    }
    

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _feeds.count) {
        [self presentFeedController:nil];
    } else {
        [self presentMapController:_feeds[indexPath.row]];
    }
    // TODO: Implement edit
    //[self presentFeedController:_feeds[indexPath.row]];
}

// TODO: implement delete
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        Feed *feed = _feeds[indexPath.row];
//        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
//            Feed *localFeed = [feed MR_inContext:localContext];
//            [localFeed MR_deleteInContext:localContext];
//        }];
//        [_feeds removeObjectAtIndex:indexPath.row];
//        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
//}

@end
