//
//  FeedsTableViewController.h
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

@class Feed;

@interface FeedsTableViewController : UITableViewController
- (void)presentMapController:(Feed *)feed;
@end
