//
//  SPOperation.h
//  Punto
//
//  Created by Jelle Vandenbeeck on 09/05/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

@interface SPOperation: NSObject
+ (id)sharedInstance;

- (void)add:(void(^)(void))batchBlock;
@end
