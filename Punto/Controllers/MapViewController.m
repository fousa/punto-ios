//
//  MapViewController.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "MapViewController.h"

#import "SPClient.h"
#import "SPParser.h"
#import "SPMessage.h"

#import "Feed.h"

#import "SVPulsingAnnotationView.h"

#import "SPAnnotation.h"

#import "SPOperation.h"

@interface MapViewController () <MKMapViewDelegate>
@end

@implementation MapViewController {
    MKMapView *_mapView;
    MKPolyline *_path;
    
    UIButton *_openButton;
    UIButton *_regionButton;
    
    SPClient *_client;
    
    MASConstraint *_fullConstraint;
    
    BOOL _initialDisplay;
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
    _regionButton.alpha = 0.0f;
    [_regionButton addTarget:self action:@selector(didPressRegion:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_regionButton];
    [_regionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_openButton.mas_left).with.offset(-10);
        make.bottom.equalTo(_openButton.mas_bottom);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    [_openButton setTitle:NSLocalizedString(@"Open", @"Open") forState:UIControlStateNormal];
    [_openButton sizeToFit];
    [_regionButton setTitle:NSLocalizedString(@"Region", @"Region") forState:UIControlStateNormal];
    [_regionButton sizeToFit];
    
    [self processFeed];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
    
    [[SPOperation sharedInstance] stop];
}

#pragma mark - Layout

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Feeds Controller

- (void)processFeed {
    __weak MapViewController *weakSelf = self;
    [[SPOperation sharedInstance] start:^{
        [weakSelf performFetch];
    }];
}

- (void)processMessages:(NSArray *)messages {
    BOOL shouldProcess = [_feed processMessages:messages];
    if (_initialDisplay || shouldProcess) {
        __weak MapViewController *weakSelf = self;
        _initialDisplay = NO;
        [SPParser parse:messages completion:^(NSError *error, MKPolyline *path, NSArray *innerMessages) {
            if (!error) [weakSelf renderPath:path withMessages:innerMessages];
        }];
    }
}

#pragma mark - Actions

- (void)didPressOpen:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didPressRegion:(id)sender {
    [_mapView setVisibleMapRect:_path.boundingMapRect edgePadding:(UIEdgeInsets) { 40, 20, 20, 20 } animated:YES];
}

#pragma mark - Map

- (void)performFetch {
    if (IsEmpty(_feed)) return;
    
    __weak MapViewController *weakSelf = self;
    [SPClient fetchMessagesForFeed:_feed completion:^(NSError *error, NSArray *messages) {
        if (error || messages.count == 0) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"There is a problem loading the feed's data. It's possible that no messages are available.", @"There is a problem loading the feed's data. It's possible that no messages are available.") delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") otherButtonTitles:nil] show];
        } else if (!error && messages.count > 0) {
            [weakSelf processMessages:messages];
        }
    }];
}

- (void)resetData {
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    
    _regionButton.alpha = 0.0f;
    _openButton.alpha = 0.0f;
}

- (void)renderPath:(MKPolyline *)path withMessages:(NSArray *)messages {
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    
    [_fullConstraint uninstall];
    [_openButton sizeToFit];
    [_openButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-10);
        make.bottom.equalTo(@-10);
    }];
    _regionButton.alpha = 1.0f;
    _openButton.alpha = 1.0f;
    
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
    [_mapView addOverlay:_path];
    [_mapView setVisibleMapRect:_path.boundingMapRect edgePadding:(UIEdgeInsets) { 40, 20, 20, 20 } animated:YES];
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
