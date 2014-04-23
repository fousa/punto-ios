//
//  MapParser.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "SPParser.h"

#import "SPMessage.h"

@implementation SPParser

+ (void)parse:(NSArray *)messages completion:(void(^)(NSError *error, MKPolyline *path, NSArray *messages))completion {
    NSInteger count = messages.count == 1 ? 2 : messages.count;
    CLLocationCoordinate2D *coordinates = malloc(sizeof(CLLocationCoordinate2D) * count);
    for(int i = 0; i < messages.count; i++) {
        SPMessage *message = messages[i];
        CLLocationCoordinate2D coordinate = [message coordinate];
        coordinates[i] = coordinate;
    }
    
    if (messages.count == 1) {
        SPMessage *message = messages[0];
        CLLocationCoordinate2D coordinate = [message coordinate];
        coordinates[1] = coordinate;
    }
    
    MKPolyline *path = [MKPolyline polylineWithCoordinates:coordinates count:count];
    free(coordinates);
    
    dispatch_async_main(^{
        if (completion) completion(nil, path, messages);
    });
}

@end
