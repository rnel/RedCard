//
//  RCMainViewController.m
//  RedCard
//
//  Created by Ronnie Liew on 12/3/14.
//  Copyright (c) 2014 Monokromik. All rights reserved.
//

@import Social;
@import Accounts;

#import <AFNetworking.h>
#import "RCMainViewController.h"
#import "RCLoginViewController.h"
#import "RCFacebookManager.h"
#import "RCConstants.h"


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
        [self getUserData];
    }
}



- (void)getUserData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    __block NSDictionary* responseForProfile;
    __block NSDictionary* responseForPicture;
    
    dispatch_group_async(group,queue,^{
        dispatch_group_enter(group);
        
        [self.fbManager GET:@"me" parameters:nil
                    success:^(id responseObject){
                        responseForProfile = responseObject;
                        dispatch_group_leave(group);
                    }
                    failure:^(NSError *error){
                        dispatch_group_leave(group);
                    }];
    });
    
    dispatch_group_async(group,queue,^{
        dispatch_group_enter(group);
        
        [self.fbManager GET:@"me/picture/"
                 parameters:@{@"redirect":@"false",  @"width":[@(RCFBProfileImageWidth * 2) stringValue]}
                    success:^(id responseObject){
                        responseForPicture = responseObject;
                        self.profileImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: responseObject[@"data"][@"url"]]]];
                        dispatch_group_leave(group);
                    }
                    failure:^(NSError *error){
                        dispatch_group_leave(group);
                    }];
    });
    
    dispatch_group_notify(group, queue, ^{
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:responseForProfile];
        parameters[@"url"] = responseForPicture[@"data"][@"url"];
        
        [manager POST:@"http://192.168.1.76:1337/addperson"
           parameters:parameters
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"JSON: %@", responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Error: %@", error);
              }];
    });
}




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
