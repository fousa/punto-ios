#import "_Feed.h"

@interface Feed : _Feed
@property (nonatomic, readonly) NSURL *URL;

- (BOOL)processMessages:(NSArray *)messages;
@end
