//
//  RCLoginViewController.h
//  RedCard
//
//  Created by Ronnie Liew on 13/3/14.
//  Copyright (c) 2014 Monokromik. All rights reserved.
//

@import Social;
@import Accounts;

#import <UIKit/UIKit.h>
#import "RCFacebookManager.h"

@interface RCLoginViewController : UIViewController
@property (nonatomic, strong) RCFacebookManager *fbManager;
@end
