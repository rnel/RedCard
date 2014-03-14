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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            [self getUserData];
        });
    }
}



- (void)getUserData {
    // Trying out using dispatch_semaphore to do wait for both calls to complete and collate the data
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    __block NSDictionary* responseForProfile;
    __block NSDictionary* responseForPicture;

    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    dispatch_async(queue, ^{

        [self.fbManager GET:@"me" parameters:nil
                    success:^(id responseObject){
                        responseForProfile = responseObject;
                        dispatch_semaphore_signal(sema);
                    }
                    failure:^(NSError *error){
                        dispatch_semaphore_signal(sema);
                    }];
    });


    dispatch_async(queue, ^{
        [self.fbManager GET:@"me/picture/"
                 parameters:@{@"redirect":@"false", @"width":[@(RCFBProfileImageWidth * 2) stringValue]}
                    success:^(id responseObject){
                        responseForPicture = responseObject;
                        self.profileImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:responseForPicture[@"data"][@"url"]]]];
                        dispatch_semaphore_signal(sema);
                    }
                    failure:^(NSError *error){
                        dispatch_semaphore_signal(sema);
                    }];

    });

    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:responseForProfile];
    parameters[@"url"] = responseForPicture[@"data"][@"url"];
    
    [manager POST:@"http://192.168.1.76:1337/addperson"
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
          }
     ];
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
