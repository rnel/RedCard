//
//  RCRegionTrigger.m
//  RedCard
//
//  Created by Ronnie Liew on 13/3/14.
//  Copyright (c) 2014 Monokromik. All rights reserved.
//

#import "RCRegionObserver.h"
#import <AFNetworking.h>
#import "RCFacebookManager.h"
#import "RCConstants.h"

@interface RCRegionObserver ()
@property (nonatomic, strong) RCFacebookManager *fbManager;
@property (nonatomic, strong) AFHTTPRequestOperationManager *HTTPRequestOperationManager;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic, strong) UILocalNotification *localNotification;
@end




@implementation RCRegionObserver

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    self = [super init];
    if (self) {
        self.fbManager = [[RCFacebookManager alloc] init];
        self.HTTPRequestOperationManager = [AFHTTPRequestOperationManager manager];
        self.localNotification = [[UILocalNotification alloc] init];
    }
    return self;
}

- (BOOL)beaconManager:(MNBeaconManager *)manager shouldAutoStartRangingBeaconsInRegion:(CLBeaconRegion *)region {
    return YES;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - MNBeaconManagerObserver
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)beaconManager:(MNBeaconManager *)manager didEnterRegion:(CLBeaconRegion *)region {
    [self presentLocalNotificationNowWithAlertBody:@"Entering region" action:@"Launch app"];
}


- (void)beaconManager:(MNBeaconManager *)manager didExitRegion:(CLBeaconRegion *)region {
    __block UIBackgroundTaskIdentifier backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(){
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }];
    
    [self.HTTPRequestOperationManager DELETE:[NSString stringWithFormat:@"http://192.168.1.76:1337/removeperson/%@", self.fbManager.UID] parameters:nil
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         [self presentLocalNotificationNowWithAlertBody:@"Info shared" action:@"Launch app"];
                                         [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                                         backgroundTask = UIBackgroundTaskInvalid;
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                                         backgroundTask = UIBackgroundTaskInvalid;
                                     }
     ];
    [self presentLocalNotificationNowWithAlertBody:@"Leaving region" action:@"Launch app"];

}



- (void)beaconManager:(MNBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSArray *nearOrImmediateBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity == %ld || proximity == %ld",
                                                                            CLProximityImmediate, CLProximityNear]];
    
    if (nearOrImmediateBeacons.count > 0) {
        [manager stopRangingBeaconsInRegion:region];
        
        self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [self presentLocalNotificationNowWithAlertBody:@"Unable to complete sharing" action:@"Launch app"];
            
            [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }];
        
        [self getUserData];
    }
    
}




- (void)getUserData {
    // Trying out using dispatch_group_notify to do wait for both calls to complete and collate the data
    AFHTTPRequestOperationManager *manager = self.HTTPRequestOperationManager;
    
    __block NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();

    
    dispatch_group_async(group,queue,^{
        dispatch_group_enter(group);
        
        [self.fbManager GET:@"me" parameters:nil
                    success:^(id responseObject){
                        [parameters addEntriesFromDictionary:responseObject];
                        dispatch_group_leave(group);
                    }
                    failure:^(NSError *error){
                        dispatch_group_leave(group);
                    }];
    });
    
    dispatch_group_async(group,queue,^{
        dispatch_group_enter(group);
        
        [self.fbManager GET:@"me/picture/"
                 parameters:@{@"redirect":@"false", @"width":[@(RCFBProfileImageWidth * 2) stringValue]}
                    success:^(id responseObject){
                        [parameters addEntriesFromDictionary:responseObject[@"data"]];
                        dispatch_group_leave(group);
                    }
                    failure:^(NSError *error){
                        dispatch_group_leave(group);
                    }];
    });
    
    dispatch_group_notify(group, queue, ^{
        [manager  POST:@"http://192.168.1.76:1337/addperson"
            parameters:parameters
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   [self presentLocalNotificationNowWithAlertBody:@"Info shared" action:@"Launch app"];
                   [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTask];
                   self.backgroundTask = UIBackgroundTaskInvalid;
               }
               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTask];
                   self.backgroundTask = UIBackgroundTaskInvalid;
               }
         ];
    });
}


- (void)presentLocalNotificationNowWithAlertBody:(NSString *)bodyString action:(NSString *)actionString {
    self.localNotification.alertBody = bodyString;
    self.localNotification.alertAction = actionString;
    self.localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:self.localNotification];
}
@end
