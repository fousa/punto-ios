//
//  MapViewController.h
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "FeedsTableViewController.h"

@interface MapViewController : UIViewController <FeedsTableViewControllerDelegate>
- (void)performFetch;
@end