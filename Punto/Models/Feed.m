#import "Feed.h"

@implementation Feed

- (NSURL *)URL {
    static NSString *apiURLString = @"https://api.findmespot.com/spot-main-web/consumer/rest-api/2.0/public/feed/";
    return [NSURL URLWithString:[apiURLString stringByAppendingString:[self extractToken]]];
}

- (NSString *)extractToken {
    static NSString *mainURLString = @"http://share.findmespot.com/shared/faces/viewspots.jsp?glId=";
    return [self.link stringByReplacingOccurrencesOfString:mainURLString withString:@""];
}

@end
