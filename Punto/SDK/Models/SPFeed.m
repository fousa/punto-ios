//
//  SPFeed.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 09/05/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "SPFeed.h"

@implementation SPFeed

+ (SPFeed *)parse:(NSDictionary *)params {
    NSDictionary *feedParams = params[@"response"][@"feedMessageResponse"][@"feed"];
    return [super parse:feedParams];
}

@end
