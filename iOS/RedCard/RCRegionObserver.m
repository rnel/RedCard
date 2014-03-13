//
//  RCRegionTrigger.m
//  RedCard
//
//  Created by Ronnie Liew on 13/3/14.
//  Copyright (c) 2014 Monokromik. All rights reserved.
//

#import "RCRegionObserver.h"

@interface RCRegionObserver ()
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;
@end


@implementation RCRegionObserver
- (BOOL)beaconManager:(MNBeaconManager *)manager shouldAutoStartRangingBeaconsInRegion:(CLBeaconRegion *)region {
    return YES;
}



- (void)beaconManager:(MNBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    UIApplication *application = [UIApplication sharedApplication];
    NSArray *nearOrImmediateBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity == %ld || proximity == %ld",
                                                                            CLProximityImmediate, CLProximityNear]];
    
    if (nearOrImmediateBeacons.count > 0) {
        [manager stopRangingBeaconsInRegion:region];
        
        self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [application endBackgroundTask: self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }];
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"Sharing info"];
        localNotification.alertAction = @"Launch app";
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        
        [application presentLocalNotificationNow:localNotification];
        
        [application endBackgroundTask: self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
    
}
@end
