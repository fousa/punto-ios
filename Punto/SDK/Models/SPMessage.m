//
//  SPMessage.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "MTLValueTransformer.h"

#import "SPMessage.h"

#import "NSString+SPFormatter.h"

@implementation SPMessage

+ (NSArray *)parseModels:(NSDictionary *)params {
    NSMutableArray *list = @[].mutableCopy;
    id messages = params[@"response"][@"feedMessageResponse"][@"messages"][@"message"];
    if ([messages isKindOfClass:[NSArray class]]) {
        [messages each:^(NSDictionary *modelParams) {
            [list addObject:[self parse:modelParams]];
        }];
    } else if (messages) {
        [list addObject:[self parse:messages]];
    }
    return list;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"date": @"dateTime",
             @"ID": @"messengerId",
             @"name": @"messengerName"
             };
}

+ (NSValueTransformer *)dateJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *dateText) {
        return [dateText date];
    } reverseBlock:^id(id date) {
        return nil;
    }];
}

#pragma mark - Coordinates

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(_latitude.doubleValue, _longitude.doubleValue);
}

@end
