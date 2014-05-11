//
//  FeedCollectionViewCell.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 11/05/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "FeedCollectionViewCell.h"

@implementation FeedCollectionViewCell {
    UILabel *_textLabel;
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) return nil;
    
    self.contentView.layer.cornerRadius = 5.0f;
    self.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.contentView.layer.borderWidth = 2.0f;
    self.contentView.backgroundColor = [UIColor blackColor];
    
    _textLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_textLabel];
    
    return self;
}

#pragma mark - Text

- (void)setLabelText:(NSString *)text {
    _textLabel.text = text;
}

@end
