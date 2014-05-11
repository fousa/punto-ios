//
//  FeedCollectionViewlayout.m
//  Punto
//
//  Created by Jelle Vandenbeeck on 11/05/14.
//  Copyright (c) 2014 Fousa. All rights reserved.
//

#import "FeedCollectionViewlayout.h"

@implementation FeedCollectionViewlayout

- (id)init {
    if (!(self = [super init])) return nil;
    
    CGFloat padding = 0;
    if (IsIPad()) {
        padding = 20.0f;
        CGFloat side = (punto.window.bounds.size.height - (padding * 6)) / 5;
        self.itemSize = CGSizeMake(side, side);
    } else {
        padding = 10.0f;
        CGFloat side = (punto.window.bounds.size.width - (padding * 5)) / 4;
        self.itemSize = CGSizeMake(side, side);
    }
    self.minimumInteritemSpacing = padding;
    self.minimumLineSpacing = padding;
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.sectionInset = UIEdgeInsetsMake(padding, padding, padding, padding);
    
    return self;
}

@end
