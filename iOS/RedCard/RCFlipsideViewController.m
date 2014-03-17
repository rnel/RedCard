//
//  RCFlipsideViewController.m
//  RedCard
//
//  Created by Ronnie Liew on 12/3/14.
//  Copyright (c) 2014 Monokromik. All rights reserved.
//

#import "RCFlipsideViewController.h"

@interface RCFlipsideViewController ()

@end

@implementation RCFlipsideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}



- (IBAction)done:(id)sender {
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
