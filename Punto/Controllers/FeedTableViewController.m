//
//  FeedTableViewController.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "FeedTableViewController.h"

#import "TextTableViewCell.h"

#import "Feed.h"

#import "NSString+URL.h"

@interface FeedTableViewController ()
@end

@implementation FeedTableViewController

- (id)init {
    if (!(self = [super initWithStyle:UITableViewStyleGrouped])) return nil;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_feed) {
        self.title = NSLocalizedString(@"Edit feed", @"Edit feed");
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didPressCancel:)];
        self.title = NSLocalizedString(@"New feed", @"New feed");
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(didPressSave:)];
    
    [self.tableView reloadData];
    
    TextTableViewCell *cell =(TextTableViewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell becomeFirstResponder];
}

#pragma mark - Layout

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Actions

- (void)didPressCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didPressSave:(id)sender {
    if (![self validate]) return;
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        Feed *feed = nil;
        if (_feed) {
            feed = [_feed MR_inContext:localContext];
        } else {
            feed = [Feed MR_createInContext:localContext];
        }
        feed.name = [self name];
        feed.link = [self link];
    }];
    
    if (_feed) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        return [self cellForSwitch:indexPath];
    } else {
        return [self cellForText:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] becomeFirstResponder];
}

#pragma mark - Validation

- (NSString *)name {
    TextTableViewCell *nameCell =(TextTableViewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return [nameCell value];
}

- (NSString *)link {
    TextTableViewCell *linkCell =(TextTableViewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    return [linkCell value];
}

- (BOOL)validate {
    if (IsEmpty([self name]) || IsEmpty([self link])) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"You should fill in all the fields in order to save the feed.", @"You should fill in all the fields in order to save the feed.") delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") otherButtonTitles:nil] show];
        return NO;
    } else if (![[self link] isValidURL]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"You should fill a correct URL in order to save the feed.", @"You should fill a correct URL in order to save the feed.") delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}

#pragma mark - Cells

- (UITableViewCell *)cellForText:(NSIndexPath *)indexPath {
    static NSString *TextCellIdentifier = @"TextCell";
    TextTableViewCell *cell = (TextTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:TextCellIdentifier];
    if (!cell) {
        cell = [[TextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextCellIdentifier];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"Name", @"Name");
        cell.placeholder = NSLocalizedString(@"Pick a name", @"Pick a name");
        if (_feed) cell.value = _feed.name;
    } else {
        cell.textLabel.text = NSLocalizedString(@"Spot link", @"Spot link");
        cell.placeholder = NSLocalizedString(@"Paste a Spot link", @"Paste a Spot link");
        if (_feed) cell.value = _feed.link;
    }
    return cell;
}

- (UITableViewCell *)cellForSwitch:(NSIndexPath *)indexPath {
    static NSString *SwitchCellIdentifier = @"SwitchCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SwitchCellIdentifier];
    }
    cell.textLabel.text = NSLocalizedString(@"Notify movement", @"Notify movement");
    return cell;
}

@end
