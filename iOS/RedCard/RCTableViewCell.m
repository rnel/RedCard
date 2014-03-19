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


- (void)setPerson:(NSDictionary *)person {
    _person = person;
    
    self.textLabel.text = [NSString stringWithFormat:@"%@ %@", person[@"first_name"], person[@"last_name"]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:person[@"url"]]];

        dispatch_sync(dispatch_get_main_queue(), ^{
            self.imageView.image = [UIImage imageWithData:imageData];
            [self setNeedsLayout];
        });
    });
}
@end
