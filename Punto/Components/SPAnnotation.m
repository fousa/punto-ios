//
//  SPAnnotation.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 16/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "SPAnnotation.h"

@implementation SPAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if (!(self = [super init])) return nil;
    
    self.coordinate = coordinate;
    
    return self;
}

@end
