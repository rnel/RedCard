//
//  RCLoginViewController.m
//  RedCard
//
//  Created by Ronnie Liew on 13/3/14.
//  Copyright (c) 2014 Monokromik. All rights reserved.
//

#import "RCLoginViewController.h"

@interface RCLoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@end

@implementation RCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}



/////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - IBAction
/////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)loginButtonTapped:(id)sender {
    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable to login"
                                                            message:@"Please sign to Facebook via the Settings app on your iPhone."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else {
        UIButton* button = (UIButton *)sender;
        button.enabled = NO;
        
        ACAccountStore *accountStore = self.fbManager.accountStore;
        ACAccountType *facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];

        [accountStore requestAccessToAccountsWithType:facebookAccountType
                                              options:@{ACFacebookAppIdKey:@"819312108084028",
                                                        ACFacebookPermissionsKey:@[@"user_birthday", @"email"],
                                                        ACFacebookAudienceKey: ACFacebookAudienceOnlyMe}
                                           completion:^(BOOL granted, NSError *error){
            if (granted) {
                self.fbManager.account = [accountStore accountsWithAccountType:facebookAccountType].firstObject;
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                NSLog(@"Login %@: %@", @(error.code), error.debugDescription);
            }
        }];
    }
}


@end
