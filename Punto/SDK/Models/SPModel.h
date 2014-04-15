//
//  SPModel.h
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@interface SPModel : MTLModel <MTLJSONSerializing>
+ (id)parse:(NSDictionary *)params;
@end
