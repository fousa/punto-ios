//
//  SPClient.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "SPClient.h"

#import "SPMessage.h"
#import "SPFeed.h"

#import "Feed.h"

#import "NSError+SPErrors.h"
#import "NSString+URL.h"

@implementation SPClient

#pragma mark - Messages

+ (void)fetchMessagesForFeeds:(NSArray *)feeds completion:(void (^)(BOOL dataFetched))completion {
    NSLog(@"-- fetchMessagesForFeeds:completion:");
    
    dispatch_group_t group = dispatch_group_create();
    
    for (Feed *feed in feeds) {
        dispatch_group_enter(group);
        [self fetchMessagesForFeed:feed completion:^(NSError *error, NSArray *messages) {
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completion) completion(feeds.count > 0);
    });
}

+ (void)fetchMessagesForFeed:(Feed *)feed completion:(void (^)(NSError *error, NSArray *messages))completion {
    NSLog(@"-- fetchMessagesForFeed:completion:");
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *URLString = [feed.URL.absoluteString stringByAppendingPathComponent:@"message.json"];
    [manager GET:URLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = [NSError errorFromResponse:responseObject];
        if (error) {
            if (completion) completion(error, nil);
        } else {
            if (completion) completion(nil, [SPMessage parseModels:responseObject]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) completion(error, nil);
    }];
}

+ (void)fetchFeedFromLink:(NSString *)link completion:(void (^)(NSError *error, SPFeed *feed))completion {
    NSLog(@"-- fetchFeedFromLink:completion:");
    
    NSString *URLString = [link formatWithToken];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    URLString = [URLString stringByAppendingPathComponent:@"message.json"];
    [manager GET:URLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = [NSError errorFromResponse:responseObject];
        if (error) {
            if (completion) completion(error, nil);
        } else {
            if (completion) completion(nil, [SPFeed parse:responseObject]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) completion(error, nil);
    }];
}

@end
