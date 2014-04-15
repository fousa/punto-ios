//
//  SPModel.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "SPModel.h"

@implementation SPModel

#pragma mark - Parsing

+ (id)parse:(NSDictionary *)params {
    return [MTLJSONAdapter modelOfClass:self.class fromJSONDictionary:params error:nil];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{};
}

@end
