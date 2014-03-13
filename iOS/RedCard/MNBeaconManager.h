//
//  MNBeaconManager.h
//  Beckoning
//
//  Created by Ronnie Liew on 14/2/14.
//  Copyright (c) 2014 Monokromik. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@protocol MNBeaconManagerObserver;


@interface MNBeaconManager : NSObject <CLLocationManagerDelegate>
@property (nonatomic, readonly) NSSet *monitoredRegions;
- (void)registerBeaconRegion:(CLBeaconRegion *)region;
- (void)unregisterBeaconRegion:(CLBeaconRegion *)region;
- (void)startRangingBeaconsInRegion:(CLBeaconRegion *)region;
- (void)stopRangingBeaconsInRegion:(CLBeaconRegion *)region;
- (void)addObserver:(id<MNBeaconManagerObserver>)observer forBeaconRegion:(CLBeaconRegion *)region;
- (void)removeObserver:(id<MNBeaconManagerObserver>)observer forBeaconRegion:(CLBeaconRegion *)region;
- (NSArray *)observersForBeaconRegion:(CLBeaconRegion *)region;
@end



@protocol MNBeaconManagerObserver <NSObject>
@optional
- (void)beaconManager:(MNBeaconManager *)manager didEnterRegion:(CLBeaconRegion *)region;
- (void)beaconManager:(MNBeaconManager *)manager didExitRegion:(CLBeaconRegion *)region;
- (void)beaconManager:(MNBeaconManager *)manager monitoringDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error;
- (BOOL)beaconManager:(MNBeaconManager *)manager shouldAutoStartRangingBeaconsInRegion:(CLBeaconRegion *)region;
- (void)beaconManager:(MNBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region;
@end

