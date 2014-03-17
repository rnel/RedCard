//
//  RCTableViewCell.m
//  RedCard
//
//  Created by Ronnie Liew on 17/3/14.
//  Copyright (c) 2014 Monokromik. All rights reserved.
//

#import "RCTableViewCell.h"

@implementation RCTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imageView.layer.cornerRadius = 20.0;
    self.imageView.clipsToBounds = YES;
}



- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, 2.0, 40.0, 40.0);
}

@end
