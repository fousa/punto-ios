//
//  NSString+SPFormatter.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "NSString+SPFormatter.h"

@implementation NSString (SPFormatter)

- (NSDate *)date {
    static NSDateFormatter *date = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        date = [NSDateFormatter new];
        [date setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
    });
    
    return [date dateFromString:self];
}

@end
