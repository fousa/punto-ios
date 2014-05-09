//
//  NSError+SPErrors.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 09/05/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "NSError+SPErrors.h"

@implementation NSError (SPErrors)

+ (NSError *)errorFromResponse:(id)responseObject {
    if (responseObject[@"response"] && responseObject[@"response"][@"errors"]) {
        NSDictionary *errors = responseObject[@"response"][@"errors"];
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errors[@"error"][@"text"],
                                    NSLocalizedFailureReasonErrorKey : errors[@"error"][@"description"] };
        return [NSError errorWithDomain:kErrorDomain code:1 userInfo:userInfo];
    }
    return nil;
}

@end
