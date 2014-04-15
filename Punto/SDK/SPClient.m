//
//  SPClient.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "SPClient.h"

#import "SPMessage.h"

@implementation SPClient

#pragma mark - Instantiate

- (id)initWithBaseURL:(NSURL *)url {
    if (!(self = [super initWithBaseURL:url])) return nil;

    self.responseSerializer = [AFJSONResponseSerializer serializer];
    __weak NSOperationQueue *weakOperationQueue = self.operationQueue;
    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [weakOperationQueue setSuspended:NO];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [weakOperationQueue setSuspended:NO];
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [weakOperationQueue setSuspended:YES];
                break;
        }
    }];
    
    return self;
}

#pragma mark - Fetch messages

- (void)fetchMessagesWithCompletion:(void(^)(NSError *error, id responseObject))completion {
    if ([self.baseURL isFileURL]) {
        NSData *data = [NSData dataWithContentsOfURL:self.baseURL];
        NSError *error = nil;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error) {
            if (completion) completion(error, nil);
        } else {
            if (completion) completion(nil, [SPMessage parseModels:responseObject]);
        }
    } else {
        [self GET:@"message.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (completion) completion(nil, [SPMessage parseModels:responseObject]);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (completion) completion(error, nil);
        }];
    }
}

@end
