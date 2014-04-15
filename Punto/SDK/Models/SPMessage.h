//
//  SPMessage.h
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "SPModel.h"

@interface SPMessage : SPModel
@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *ID;

+ (NSArray *)parseModels:(NSDictionary *)params;
@end