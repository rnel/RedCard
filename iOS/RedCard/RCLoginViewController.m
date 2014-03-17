//
//  RCLoginViewController.m
//  RedCard
//
//  Created by Ronnie Liew on 13/3/14.
//  Copyright (c) 2014 Monokromik. All rights reserved.
//

#import "RCLoginViewController.h"
#import "MNBeaconManager.h"
#import "RCConstants.h"

@interface RCLoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@end

@implementation RCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}



- (void)registerBeaconRegion {
    MNBeaconManager *beaconManager = [[MNBeaconManager alloc] init];
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:RCProximityUUIDString]
                                                                     major:RCBeaconMajorPurple
                                                                identifier:RCProximityIdentifier];
    [beaconManager registerBeaconRegion:region];
}



/////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - IBAction
/////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)loginButtonTapped:(id)sender {
    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable to login"
                                                            message:@"Please add your Facebook account via the Settings app on your iPhone."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else {
        UIButton* button = (UIButton *)sender;
        button.enabled = NO;

        [self.fbManager loginWithCompletion:^(BOOL success) {
            if (success) {
                [self registerBeaconRegion];
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                button.enabled = YES;
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Sign-in failed"
                                                                    message:@"Please try again later."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Okay"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }
}



@end
