//
//  FeedsTableViewController.h
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

@class FeedsTableViewController;
@class Feed;

@protocol FeedsTableViewControllerDelegate <NSObject>
@required
- (void)feedsController:(FeedsTableViewController *)controller didSelectFeed:(Feed *)feed;
@end

@interface FeedsTableViewController : UITableViewController
@property (nonatomic, weak) id <FeedsTableViewControllerDelegate>delegate;
@end
