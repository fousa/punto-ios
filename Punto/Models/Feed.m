#import "Feed.h"

#import "SPMessage.h"

@implementation Feed

- (NSURL *)URL {
    return [[NSBundle mainBundle] URLForResource:@"ls8" withExtension:@"json"];
    
//    static NSString *apiURLString = @"https://api.findmespot.com/spot-main-web/consumer/rest-api/2.0/public/feed/";
//    return [NSURL URLWithString:[apiURLString stringByAppendingString:[self extractToken]]];
}

- (NSString *)extractToken {
    static NSString *mainURLString = @"http://share.findmespot.com/shared/faces/viewspots.jsp?glId=";
    return [self.link stringByReplacingOccurrencesOfString:mainURLString withString:@""];
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
