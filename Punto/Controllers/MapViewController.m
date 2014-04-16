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

@interface MapViewController () <MKMapViewDelegate, FeedsTableViewControllerDelegate>
@end

@implementation MapViewController {
    MKMapView *_mapView;
    
    UIButton *_openButton;
    
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_openButton setTitle:NSLocalizedString(@"Open", @"Open") forState:UIControlStateNormal];
    [_openButton sizeToFit];
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

#pragma mark - Map

- (void)resetData {
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
}

- (void)renderPath:(MKPolyline *)path withMessages:(NSArray *)messages {
    [self resetData];
    
    [messages each:^(SPMessage *message) {
        MKPointAnnotation *pin = [MKPointAnnotation new];
        pin.coordinate = [message coordinate];
        pin.title = [message.date description];
        [_mapView addAnnotation:pin];
    }];
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

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:MKUserLocation.class]) return nil;
    
    MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MKPinAnnotationView"];
    view.canShowCallout = YES;
    view.pinColor = MKPinAnnotationColorGreen;
    
    return view;
}

@end
