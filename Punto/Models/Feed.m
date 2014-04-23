#import "Feed.h"

#import "SPMessage.h"

#import "NSString+URL.h"

@implementation Feed

- (NSURL *)URL {
    if (kUseLocalFile) {
        return [NSURL fileURLWithPath:[self.link formatWithToken]];
    } else {
        return [NSURL URLWithString:[self.link formatWithToken]];
    }
}

#pragma mark - Processing

- (BOOL)shouldProcessMessages:(NSArray *)messages {
    SPMessage *lastMessage = [messages firstObject];
    if (lastMessage && (IsEmpty(self.lastUpdated) || [lastMessage.date compare:self.lastUpdated] == NSOrderedDescending)) {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            Feed *innerFeed = [self MR_inContext:localContext];
            innerFeed.lastUpdated = lastMessage.date;
        }];
        return YES;
    }
    return NO;
}

@end
