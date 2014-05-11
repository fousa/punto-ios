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

@interface FeedsTableViewController ()
@end

@implementation FeedsTableViewController {
    NSMutableArray *_feeds;
}

#pragma mark - View

+ (id)new {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    [layout setItemSize:CGSizeMake(200, 200)];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    return [[self alloc] initWithCollectionViewLayout:layout];
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"FeedCell"];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"AddCell"];
    
    self.collectionView.backgroundColor = [UIColor redColor];
    
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

#pragma mark - Actions

- (void)didPressAdd:(id)sender {
    [self presentFeedController:nil];
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
    return _feeds.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FeedCell" forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor blueColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:cell.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = 1;
    [cell.contentView addSubview:label];
    
    Feed *feed = _feeds[indexPath.row];
    label.text = feed.name;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self presentMapController:_feeds[indexPath.row]];
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
