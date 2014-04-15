//
//  TextTableViewCell.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 15/04/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "TextTableViewCell.h"

@implementation TextTableViewCell {
    UITextField *_field;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    _field = [[UITextField alloc] initWithFrame:(CGRect) { 0, 0, 150.0f, 30.0f }];
    _field.textAlignment = NSTextAlignmentRight;
    self.accessoryView = _field;
    
    return self;
}

#pragma mark - Value

- (NSString *)value {
    return _field.text;
}

- (void)setValue:(NSString *)value {
    _field.text = value;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _field.placeholder = placeholder;
}

#pragma mark - Responder

- (BOOL)becomeFirstResponder {
    return [_field becomeFirstResponder];
}

@end
