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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.allowsSelectionDuringEditing = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataChanged:) name:kDataChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"My Spots", @"My Spots");
    
    [self setLeftBarButtonItem:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDataChangedNotification object:nil];
}

#pragma mark - Layout

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Notifications

- (void)dataChanged:(NSNotification *)notification {
    _feeds = [Feed MR_findAllSortedBy:@"name" ascending:YES].mutableCopy;
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)didPressClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *FeedCellIdentifier = @"FeedCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FeedCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:FeedCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    Feed *feed = _feeds[indexPath.row];
    cell.textLabel.text = feed.name;
    cell.detailTextLabel.text = [feed.lastUpdated description];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing) {
        [self presentFeedController:_feeds[indexPath.row]];
    } else {
        [self presentMapController:_feeds[indexPath.row]];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Feed *feed = _feeds[indexPath.row];
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            Feed *localFeed = [feed MR_inContext:localContext];
            [localFeed MR_deleteInContext:localContext];
        }];
        [_feeds removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    [self setLeftBarButtonItem:animated];
}

- (void)setLeftBarButtonItem:(BOOL)animated {
    if (self.tableView.editing) {
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didPressAdd:)] animated:animated];
    } else {
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Close") style:UIBarButtonItemStylePlain target:self action:@selector(didPressClose:)] animated:animated];
    }
}

@end
