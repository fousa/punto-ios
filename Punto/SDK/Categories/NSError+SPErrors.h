//
//  NSError+SPErrors.h
//  Punto
//
//  Created by Jelle Vandenbeeck on 09/05/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

@interface NSError (SPErrors)
+ (NSError *)errorFromResponse:(id)responseObject;
@end
