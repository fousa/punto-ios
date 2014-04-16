//
//  MapParser.h
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface SPParser : NSObject
+ (void)parse:(NSArray *)messages completion:(void(^)(NSError *error, MKPolyline *path, NSArray *messages))completion;
@end
