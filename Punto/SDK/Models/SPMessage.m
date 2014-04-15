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
    [params[@"response"][@"feedMessageResponse"][@"messages"][@"message"] each:^(NSDictionary *modelParams) {
        [list addObject:[self parse:modelParams]];
    }];
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

@end
