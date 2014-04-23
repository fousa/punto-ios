//
//  SPClient.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "SPClient.h"

#import "SPMessage.h"

#import "Feed.h"

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
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) return;
    
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

#pragma mark - Background fetch

+ (void)fetchMessages:(void (^)(BOOL dataFetched))completion {
    dispatch_group_t group = dispatch_group_create();
    NSArray *feeds = [Feed MR_findByAttribute:@"notify" withValue:@(YES)];
    for (NSInteger index = 0; index < feeds.count; index++) {
        dispatch_group_enter(group);
        [self fetchMessage:feeds[index] completion:^ {
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completion) completion(feeds.count > 0);
    });
}

+ (void)fetchMessage:(Feed *)feed completion:(void (^)(void))completion {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *URLString = [feed.URL.absoluteString stringByAppendingPathComponent:@"message.json"];
    [manager GET:URLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *messages = [SPMessage parseModels:responseObject];
        BOOL shouldProcess = [feed shouldProcessMessages:messages];
        if (shouldProcess) {
            UILocalNotification *localNotification = [UILocalNotification new];
            localNotification.fireDate = [NSDate date];
            localNotification.timeZone = [NSTimeZone systemTimeZone];
            localNotification.alertAction = NSLocalizedString(@"Show", @"Show");
            localNotification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"We noticed some movement by %@", @"We noticed some movement in the '%@' feed."), feed.name];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
        if (completion) completion();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) completion();
    }];
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
        [NSThread sleepForTimeInterval:60.0f];
        [_blockedSelf batch];
    }];
}

@end
