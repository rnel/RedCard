//
//  RCMainViewController.m
//  RedCard
//
//  Created by Ronnie Liew on 12/3/14.
//  Copyright (c) 2014 Monokromik. All rights reserved.
//

@import Social;
@import Accounts;

#import "RCMainViewController.h"
#import "RCLoginViewController.h"
#import "RCFacebookManager.h"


@interface RCMainViewController ()

@property (nonatomic, strong) RCFacebookManager *fbManager;
@property (nonatomic, strong) ACAccount *account;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@end

@implementation RCMainViewController

/////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController
/////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fbManager = [[RCFacebookManager alloc] init];
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.clipsToBounds = YES;

}



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    if (!self.fbManager.account) {
        RCLoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RCLoginViewController"];
        loginViewController.fbManager = self.fbManager;

        [self presentViewController:loginViewController animated:YES completion:nil];
    }
    else{
        [self.fbManager get:@"me" parameters:nil];
    }
}




//- (void)get {
//    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", [self.account valueForKeyPath:@"properties.uid"]]];
//    
//    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET
//                                                      URL:requestURL
//                                               parameters:@{@"redirect":@"true", @"width":[@(self.profileImageView.frame.size.width * 2) stringValue]}];
//    request.account = self.account;
//    
//    [request performRequestWithHandler:^(NSData *data,
//                                         NSHTTPURLResponse *response,
//                                         NSError *error) {
//        
//        if(!error) {
//            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET
//                                              URL:[NSURL URLWithString: @"https://graph.facebook.com/me"]
//                                  parameters:nil];
//            request.account = self.account;
//
//            [request performRequestWithHandler:^(NSData *data,
//                                                 NSHTTPURLResponse *response,
//                                                 NSError *error) {
//                if (!error){
//                    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingAllowFragments error: &error];
//                    NSLog(@"Request %@", JSON);
//                }
//                
//                
//            }];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.profileImageView.image = [[UIImage alloc] initWithData:data];
//            });
//        }
//        else{
//            NSLog(@"error from get%@",error);
//        }
//    }];
//}




/////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Flipside View
/////////////////////////////////////////////////////////////////////////////////////////////////
- (void)flipsideViewControllerDidFinish:(RCFlipsideViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

@end
