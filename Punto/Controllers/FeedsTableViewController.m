//
//  FeedsTableViewController.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "FeedsTableViewController.h"

#import "Feed.h"

@interface FeedsTableViewController ()
@end

@implementation FeedsTableViewController {
    NSMutableArray *_feeds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"My Spots", @"My Spots");
    
    [self setLeftBarButtonItem:animated];
    
    _feeds = [Feed MR_findAllSortedBy:@"name" ascending:YES].mutableCopy;
}

#pragma mark - Actions

- (void)didPressClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didPressAdd:(id)sender {
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *FeedCellIdentifier = @"FeedCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FeedCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeedCellIdentifier];
}
    cell.textLabel.text = @(indexPath.row).stringValue;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"remove path %@", indexPath);
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
