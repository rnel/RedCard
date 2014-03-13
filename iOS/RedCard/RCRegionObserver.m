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
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;
@end




@implementation RCRegionObserver

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    self = [super init];
    if (self) {
       self.fbManager = [[RCFacebookManager alloc] init];
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
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = [NSString stringWithFormat:@"Entering region: %@", region.identifier];
    localNotification.alertAction = @"Launch app";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}


- (void)beaconManager:(MNBeaconManager *)manager didExitRegion:(CLBeaconRegion *)region {
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = [NSString stringWithFormat:@"Exiting beacons: %@", region.identifier];
    localNotification.alertAction = @"Launch app";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}



- (void)beaconManager:(MNBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSArray *nearOrImmediateBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity == %ld || proximity == %ld",
                                                                            CLProximityImmediate, CLProximityNear]];
    
    if (nearOrImmediateBeacons.count > 0) {
        [manager stopRangingBeaconsInRegion:region];
        
        self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertBody = [NSString stringWithFormat:@"Unable to complete sharing info"];
            localNotification.alertAction = @"Launch app";
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            
            [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }];
        
        [self getUserData];
    }
    
}




- (void)getUserData {
    // Trying out using dispatch_group_notify to do wait for both calls to complete and collate the data
    
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
                 parameters:@{@"redirect":@"false", @"width":[@(RCFBProfileImageWidth * 2) stringValue]}
                    success:^(id responseObject){
                        responseForPicture = responseObject;
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
@end
