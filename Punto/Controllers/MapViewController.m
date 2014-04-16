//
//  MapViewController.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "MapViewController.h"
#import "FeedsTableViewController.h"

#import "SPClient.h"
#import "SPParser.h"
#import "SPMessage.h"

#import "Feed.h"

#import "SVPulsingAnnotationView.h"

#import "SPAnnotation.h"

@interface MapViewController () <MKMapViewDelegate, FeedsTableViewControllerDelegate>
@end

@implementation MapViewController {
    MKMapView *_mapView;
    MKPolyline *_path;
    
    UIButton *_openButton;
    UIButton *_regionButton;
    
    SPClient *_client;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak MapViewController *weakSelf = self;
    
    // Add map view
    _mapView = [MKMapView new];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view).with.insets((UIEdgeInsets) { 0, 0, 0, 0 });
    }];
    
    // Add open button
    _openButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _openButton.backgroundColor = [UIColor whiteColor];
    [_openButton addTarget:self action:@selector(didPressOpen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_openButton];
    [_openButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-10);
        make.bottom.equalTo(@-10);
    }];
    
    // Add region button
    _regionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _regionButton.backgroundColor = [UIColor whiteColor];
    [_regionButton addTarget:self action:@selector(didPressRegion:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_regionButton];
    [_regionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_openButton.mas_left).with.offset(-10);
        make.bottom.equalTo(_openButton.mas_bottom);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_openButton setTitle:NSLocalizedString(@"Open", @"Open") forState:UIControlStateNormal];
    [_openButton sizeToFit];
    [_regionButton setTitle:NSLocalizedString(@"Region", @"Region") forState:UIControlStateNormal];
    [_regionButton sizeToFit];
}

#pragma mark - Layout

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Feeds Controller

- (void)feedsController:(FeedsTableViewController *)controller didSelectFeed:(Feed *)feed {
    [self resetData];
    
    __weak MapViewController *weakSelf = self;
    _client = [[SPClient alloc] initWithBaseURL:feed.URL];
    [_client startfetchingMessagesWithCompletion:^(NSError *error, id responseObject) {
        if (!error) {
            [SPParser parse:responseObject completion:^(NSError *error, MKPolyline *path, NSArray *messages) {
                if (!error) [weakSelf renderPath:path withMessages:messages];
            }];
        }
    }];
}

#pragma mark - Actions

- (void)didPressOpen:(id)sender {
    FeedsTableViewController *feedsController = [FeedsTableViewController new];
    feedsController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:feedsController];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)didPressRegion:(id)sender {
    [_mapView setVisibleMapRect:_path.boundingMapRect edgePadding:(UIEdgeInsets) { 40, 20, 20, 20 } animated:YES];
}

#pragma mark - Map

- (void)resetData {
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
}

- (void)renderPath:(MKPolyline *)path withMessages:(NSArray *)messages {
    [self resetData];
    
    __block NSInteger index = 0;
    [messages each:^(SPMessage *message) {
        SPAnnotation *pin = [[SPAnnotation alloc] initWithCoordinate:[message coordinate]];
        pin.title = [message.date description];
        if (index == 0) {
            pin.subtitle = NSLocalizedString(@"Last position", @"Last position");
            pin.last = YES;
        }
        [_mapView addAnnotation:pin];
        index += 1;
    }];
    
    _path = path;
    [_mapView addOverlay:path];
    [_mapView setVisibleMapRect:path.boundingMapRect edgePadding:(UIEdgeInsets) { 40, 20, 20, 20 } animated:YES];
}

#pragma mark Map delegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *pathView = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    pathView.strokeColor = [UIColor redColor];
    pathView.lineWidth = 3.0;
    
    return pathView;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation isKindOfClass:[SPAnnotation class]]) {
        static NSString *AnnotationIdentifier = @"SPAnnotationIdentifier";
		SVPulsingAnnotationView *view = (SVPulsingAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
		if (view == nil) {
			view = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
            view.annotationColor = [UIColor colorWithRed:0.194 green:0.678 blue:0.177 alpha:1.000];
            view.canShowCallout = YES;
        }
        view.delayBetweenPulseCycles = ((SPAnnotation *)annotation).last ? 0 : INFINITY;
		
		return view;
    }
    
    return nil;
}

@end
