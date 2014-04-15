//
//  SPClient.h
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface SPClient : AFHTTPRequestOperationManager
- (void)startfetchingMessagesWithCompletion:(void(^)(NSError *error, id responseObject))completion;
@end
