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

@interface MapViewController () <MKMapViewDelegate>
@end

@implementation MapViewController {
    MKMapView *_mapView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mapView = [MKMapView new];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    
    __weak MapViewController *weakSelf = self;
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view).with.insets((UIEdgeInsets) { 0, 0, 0, 0 });
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __weak MapViewController *weakSelf = self;
    
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"ls8" withExtension:@"json"];
    SPClient *client = [[SPClient alloc] initWithBaseURL:fileURL];
    [client fetchMessagesWithCompletion:^(NSError *error, id responseObject) {
        NSLog(@"--- fetch error: %@", error);
        NSLog(@"--- responseObject: %@", responseObject);
        if (!error) {
            [SPParser parse:responseObject completion:^(NSError *error, MKPolyline *path) {
                NSLog(@"--- parse error: %@", error);
                if (!error) [weakSelf renderPath:path];
            }];
        }
    }];
}

#pragma mark - Map

- (void)renderPath:(MKPolyline *)path {
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView addOverlay:path];
}

#pragma mark Map delegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *pathView = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    pathView.strokeColor = [UIColor redColor];
    pathView.lineWidth = 4.0;
    
    return pathView;
}

@end
