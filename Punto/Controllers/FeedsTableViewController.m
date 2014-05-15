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

#import "FeedCollectionViewlayout.h"

@interface FeedsTableViewController () <UIGestureRecognizerDelegate>
@end

@implementation FeedsTableViewController {
    NSMutableArray *_feeds;
}

#pragma mark - View

+ (id)new {
    return [[self alloc] initWithCollectionViewLayout:[FeedCollectionViewlayout new]];
}

+ (CGSize)deviceItemSize {
    return CGSizeMake(0, 0);
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.925 alpha:1.000];
    [self.collectionView registerClass:[FeedCollectionViewCell class] forCellWithReuseIdentifier:@"FeedCell"];
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    gesture.minimumPressDuration = .5;
    gesture.delegate = self;
    [self.collectionView addGestureRecognizer:gesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataChanged:) name:kDataChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"My Spots", @"My Spots");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDataChangedNotification object:nil];
}

#pragma mark - Status bar

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Gestures

- (void)longTap:(UIGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    if (indexPath && indexPath.row < _feeds.count) {
        Feed *feed = _feeds[indexPath.row];
        [self presentFeedController:feed];
    }
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
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:feedController];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
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
}

@end
