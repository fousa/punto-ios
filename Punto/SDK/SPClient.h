//
//  SPClient.h
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@class Feed;
@class SPFeed;

@interface SPClient : AFHTTPRequestOperationManager
/**
 *  Fetch messages for multiple feeds.
 *
 *  @param feeds      The feeds for which the messages are to be fetched.
 *  @param completion The block is called on completion.
 */
+ (void)fetchMessagesForFeeds:(NSArray *)feeds completion:(void (^)(BOOL dataFetched))completion;

/**
 *  Fetch all the messages for a feed.
 *
 *  @param feed       The feed for which the messages are fetched.
 *  @param completion This block is called on completion.
 */
+ (void)fetchMessagesForFeed:(Feed *)feed completion:(void (^)(NSError *error, NSArray *messages))completion;

/**
 *  Fetch the feed from a link.
 *
 *  @param link       The link used to fetch the feed.
 *  @param completion This block is called on completion.
 */
+ (void)fetchFeedFromLink:(NSString *)link completion:(void (^)(NSError *error, SPFeed *feed))completion;
@end
