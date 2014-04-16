//
//  SPAnnotation.h
//  Punto
//
//  Created by Jelle Vandenbeeck on 16/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface SPAnnotation : NSObject <MKAnnotation>
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) BOOL last;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
@end
