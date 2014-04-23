//
//  NSString+URL.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 21/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "NSString+URL.h"

@implementation NSString (URL)

- (BOOL)isValidURL {
    NSUInteger length = [self length];
    // Empty strings should return NO
    if (length > 0) {
        NSError *error = nil;
        NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        if (dataDetector && !error) {
            NSRange range = NSMakeRange(0, length);
            NSRange notFoundRange = (NSRange){NSNotFound, 0};
            NSRange linkRange = [dataDetector rangeOfFirstMatchInString:self options:0 range:range];
            if (!NSEqualRanges(notFoundRange, linkRange) && NSEqualRanges(range, linkRange)) {
                return YES;
            }
        }
        else {
            NSLog(@"Could not create link data detector: %@ %@", [error localizedDescription], [error userInfo]);
        }
    }
    return NO;
}

- (NSString *)formatWithToken {
    if (kUseLocalFile) {
        return [[NSBundle mainBundle] pathForResource:@"ls8" ofType:@"json"];
    } else {
        static NSString *apiURLString = @"https://api.findmespot.com/spot-main-web/consumer/rest-api/2.0/public/feed/";
        return [apiURLString stringByAppendingString:[self extractToken]];
    }
}

- (NSString *)extractToken {
    static NSString *mainURLString = @"http://share.findmespot.com/shared/faces/viewspots.jsp?glId=";
    return [self stringByReplacingOccurrencesOfString:mainURLString withString:@""];
}

@end
