//
//  FeedTableViewController.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "FeedTableViewController.h"

#import "TextTableViewCell.h"
#import "SwitchTableViewCell.h"

#import "Feed.h"

#import "SPClient.h"

#import "NSString+URL.h"

@interface FeedTableViewController () <UIAlertViewDelegate>
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
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    
    if (_feed) {
        self.title = NSLocalizedString(@"Edit feed", @"Edit feed");
    } else {
        self.title = NSLocalizedString(@"New feed", @"New feed");
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didPressCancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(didPressSave:)];
    
    [self.tableView reloadData];
    
    TextTableViewCell *cell =(TextTableViewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell becomeFirstResponder];
}

#pragma mark - Status bar

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Actions

- (void)didPressCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didPressSave:(id)sender {
    if (![self validate]) return;
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activity startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
    
    NSString *URLString = [[self link] formatWithToken];
    [SPClient fetchFeedFromLink:URLString completion:^(NSError *error, SPFeed *innerFeed) {
        if (error) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(didPressSave:)];
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"There was a problem connecting to the Spot service, please fill in the correct URL.", @"There was a problem connecting to the Spot service, please fill in the correct URL.") delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") otherButtonTitles:nil] show];
        } else {
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                Feed *feed = nil;
                if (_feed) {
                    feed = [_feed MR_inContext:localContext];
                } else {
                    feed = [Feed MR_createInContext:localContext];
                }
                feed.name = [self name];
                feed.link = [self link];
                feed.uniqueIdentifier = [[self link] extractToken];
                feed.notifyValue = [self notify];
            }];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kDataChangedNotification object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _feed ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 3 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        return [self cellForSwitch:indexPath];
    } else if (indexPath.section == 0) {
        return [self cellForText:indexPath];
    } else {
        return [self cellForButton:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [[tableView cellForRowAtIndexPath:indexPath] becomeFirstResponder];
    } else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete feed", @"Delete feed") message:NSLocalizedString(@"Are you sure you want to delete the current feed?", @"Are you sure you want to delete the current feed?") delegate:self cancelButtonTitle:NSLocalizedString(@"No", @"No") otherButtonTitles:NSLocalizedString(@"Delete", @"Delete"), nil] show];
    }
}

#pragma mark - Alert

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            Feed *localFeed = [_feed MR_inContext:localContext];
            [localFeed MR_deleteInContext:localContext];
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDataChangedNotification object:nil];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
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

- (BOOL)notify {
    SwitchTableViewCell *notifyCell =(SwitchTableViewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    return [notifyCell value];
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

- (UITableViewCell *)cellForButton:(NSIndexPath *)indexPath {
    static NSString *ButtonCellIdentifier = @"ButtonCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ButtonCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ButtonCellIdentifier];
        cell.backgroundColor = [UIColor redColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    cell.textLabel.text = NSLocalizedString(@"Delete feed", @"Delete feed");
    return cell;
}

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
    SwitchTableViewCell *cell = (SwitchTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:SwitchCellIdentifier];
    if (!cell) {
        cell = [[SwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SwitchCellIdentifier];
    }
    cell.textLabel.text = NSLocalizedString(@"Notify movement", @"Notify movement");
    if (_feed) cell.value = _feed.notifyValue;
    return cell;
}

@end
