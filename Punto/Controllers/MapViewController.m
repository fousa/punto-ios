//
//  MapViewController.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "MapViewController.h"

@interface MapViewController ()
@end

@implementation MapViewController {
    MKMapView *_mapView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mapView = [MKMapView new];
    [self.view addSubview:_mapView];
    
    __weak MapViewController *weakSelf = self;
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view).with.insets((UIEdgeInsets) { 0, 0, 0, 0 });
    }];
}

@end
