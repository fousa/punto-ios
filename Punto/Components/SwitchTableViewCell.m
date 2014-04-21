//
//  SwitchTableViewCell.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 21/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "SwitchTableViewCell.h"

@implementation SwitchTableViewCell {
    UISwitch *_switch;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    _switch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.accessoryView = _switch;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return self;
}

#pragma mark - Value

- (BOOL)value {
    return _switch.on;
}

- (void)setValue:(BOOL)value {
    _switch.on = value;
}

#pragma mark - Responder

- (BOOL)becomeFirstResponder {
    [_switch setOn:!_switch.on animated:YES];
    return YES;
}

@end
