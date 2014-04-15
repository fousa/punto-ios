//
//  TextTableViewCell.h
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

@interface TextTableViewCell : UITableViewCell
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *placeholder;

- (BOOL)becomeFirstResponder;
@end
