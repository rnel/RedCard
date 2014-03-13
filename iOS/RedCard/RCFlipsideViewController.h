//
//  RCFlipsideViewController.h
//  RedCard
//
//  Created by Ronnie Liew on 12/3/14.
//  Copyright (c) 2014 Monokromik. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCFlipsideViewController;

@protocol RCFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(RCFlipsideViewController *)controller;
@end

@interface RCFlipsideViewController : UIViewController

@property (weak, nonatomic) id <RCFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
