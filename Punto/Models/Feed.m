#import "Feed.h"

#import "SPMessage.h"

@implementation Feed

- (NSURL *)URL {
    static NSString *apiURLString = @"https://api.findmespot.com/spot-main-web/consumer/rest-api/2.0/public/feed/";
    return [NSURL URLWithString:[apiURLString stringByAppendingString:[self extractToken]]];
}

- (NSString *)extractToken {
    static NSString *mainURLString = @"http://share.findmespot.com/shared/faces/viewspots.jsp?glId=";
    return [self.link stringByReplacingOccurrencesOfString:mainURLString withString:@""];
}

#pragma mark - Processing

- (BOOL)shouldProcessMessages:(NSArray *)messages {
    SPMessage *lastMessage = [messages first];
    if (lastMessage && (IsEmpty(self.lastMessageIdentifier) || ![lastMessage.ID isEqualToString:self.lastMessageIdentifier])) {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            Feed *innerFeed = [self MR_inContext:localContext];
            innerFeed.lastMessageIdentifier = lastMessage.ID;
        }];
        return YES;
    }
    return NO;
}

@end
