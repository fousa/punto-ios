//
//  SPOperation.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 09/05/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "SPOperation.h"

@implementation SPOperation {
    dispatch_queue_t _queue;
}

#pragma mark - Initialization

+ (id)sharedInstance {
    static SPOperation *_operationQueue;
    static dispatch_once_t onceOperationQueueToken;
    dispatch_once(&onceOperationQueueToken, ^{
        _operationQueue = [SPOperation new];
    });
    return _operationQueue;
}

- (id)init {
    if (!(self = [super init])) return nil;
    
    _queue = dispatch_queue_create([@"SPOT_FETCHING_QUEUE" UTF8String], NULL);
    
    return self;
}

#pragma mark - Batch

- (void)add:(void(^)(void))batchBlock {
    __weak id _blockedSelf = self;
    [self addToQueue:^{
        if (batchBlock) batchBlock();
    }];
    [self addToQueue:^{
        [NSThread sleepForTimeInterval:60.0f];
        [_blockedSelf add:batchBlock];
    }];
}

- (void)addToQueue:(void (^)(void))block {
    dispatch_async(_queue, block);
}

@end
