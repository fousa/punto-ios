//
//  SPClient.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "SPClient.h"

#import "SPMessage.h"

@implementation SPClient {
    dispatch_queue_t _queue;
    
    void(^_completionCallback)(NSError *error, id responseObject);
}

#pragma mark - Instantiate

- (id)initWithBaseURL:(NSURL *)url {
    if (!(self = [super initWithBaseURL:url])) return nil;
    
    _queue = dispatch_queue_create([@"BATCH_DISPATCH_QUEUE" UTF8String], NULL);

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

- (void)startfetchingMessagesWithCompletion:(void(^)(NSError *error, id responseObject))completion {
    _completionCallback = completion;
    [self batch];
}

- (void)fetchMessages {
    if ([self.baseURL isFileURL]) {
        NSData *data = [NSData dataWithContentsOfURL:self.baseURL];
        NSError *error = nil;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error) {
            if (_completionCallback) _completionCallback(error, nil);
        } else {
            if (_completionCallback) _completionCallback(nil, [SPMessage parseModels:responseObject]);
        }
    } else {
        [self GET:@"message.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (_completionCallback) _completionCallback(nil, [SPMessage parseModels:responseObject]);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (_completionCallback) _completionCallback(error, nil);
        }];
    }
}

#pragma mark - Batch

- (void)addToQueue:(void (^)(void))block {
    dispatch_async(_queue, block);
}

- (void)batch {
    __weak id _blockedSelf = self;
    [self addToQueue:^{
        [_blockedSelf fetchMessages];
    }];
    [self addToQueue:^{ 
        [NSThread sleepForTimeInterval:5.0f];
        [_blockedSelf batch];
    }];
}

@end
