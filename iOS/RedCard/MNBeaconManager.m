//
//  MNBeaconManager.m
//  Beckoning
//
//  Created by Ronnie Liew on 14/2/14.
//  Copyright (c) 2014 Monokromik. All rights reserved.
//

#import "MNBeaconManager.h"

@interface MNBeaconManager ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableDictionary *keyedObservers;
@end


@implementation MNBeaconManager
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.keyedObservers = [NSMutableDictionary dictionary];
    }
    return self;
}



/////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////////////////////////////
- (NSSet *)monitoredRegions {
    return self.locationManager.monitoredRegions;
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Observers
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addObserver:(id<MNBeaconManagerObserver>)observer forBeaconRegion:(CLBeaconRegion *)region {
    NSString *regionIdentifier = region.identifier;
    NSPointerArray *observersForBeaconRegion = self.keyedObservers[regionIdentifier];
    
    if (observersForBeaconRegion) {
        NSUInteger index = [self indexOfObserver:observer inObservers:observersForBeaconRegion];
        
        if (index == NSNotFound) {
            [observersForBeaconRegion addPointer:(__bridge void *)(observer)];
        }
        else {
            [observersForBeaconRegion replacePointerAtIndex:index withPointer:(__bridge void *)observer];
        }
        
    }
    else {
        NSPointerArray *newObservers = [NSPointerArray weakObjectsPointerArray];
        [newObservers addPointer:(__bridge void *)(observer)];
        self.keyedObservers[regionIdentifier] = newObservers;
    }
}



- (void)removeObserver:(id<MNBeaconManagerObserver>)observer forBeaconRegion:(CLBeaconRegion *)region {
    NSString *regionIdentifier = region.identifier;
    NSPointerArray *observersForBeaconRegion = self.keyedObservers[regionIdentifier];
    
    if (observersForBeaconRegion) {
        NSUInteger index = [self indexOfObserver:observer inObservers:observersForBeaconRegion];
        
        if (index != NSNotFound) {
            [observersForBeaconRegion removePointerAtIndex:index];
        }
        
    }
}


- (NSArray *)observersForBeaconRegion:(CLBeaconRegion *)region {
    NSString *regionIdentifier = region.identifier;
    NSPointerArray *observersForBeaconRegion = self.keyedObservers[regionIdentifier];
    
    return [observersForBeaconRegion allObjects] ?: [NSArray array];
}



- (NSUInteger)indexOfObserver:(id<MNBeaconManagerObserver>)observer inObservers:(NSPointerArray *)observers {
    NSUInteger index = 0;
    
    for (id<MNBeaconManagerObserver>existingObserver in observers) {
        if (existingObserver == observer) return index;
        index++;
    }
    
    return NSNotFound;
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Beacon region
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)registerBeaconRegion:(CLBeaconRegion *)region {
    [self.locationManager startMonitoringForRegion:region];
    [self.locationManager requestStateForRegion:region];
}


- (void)unregisterBeaconRegion:(CLBeaconRegion *)region {
    [self.locationManager stopMonitoringForRegion:region];
    
}


- (void)startRangingBeaconsInRegion:(CLBeaconRegion *)region {
    if ([CLLocationManager isRangingAvailable]) {
        [self.locationManager startRangingBeaconsInRegion:region];
    }
}


- (void)stopRangingBeaconsInRegion:(CLBeaconRegion *)region {
    if ([CLLocationManager isRangingAvailable]) {
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CLLocationManagerDelegate
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    NSPointerArray *observersForRegion = self.keyedObservers[region.identifier];
    
    for (id<MNBeaconManagerObserver>observer in observersForRegion) {
        if ([observer respondsToSelector:@selector(beaconManager:didEnterRegion:)]) {
            [observer beaconManager:self didEnterRegion:beaconRegion];
        }
    }
}



- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSPointerArray *observersForRegion = self.keyedObservers[region.identifier];
    
    for (id<MNBeaconManagerObserver>observer in observersForRegion) {
        if ([observer respondsToSelector:@selector(beaconManager:didExitRegion:)]) {
            [observer beaconManager:self didExitRegion:(CLBeaconRegion *)region];
        }
        
    }
}



- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSPointerArray *observersForRegion = self.keyedObservers[region.identifier];
    
    for (id<MNBeaconManagerObserver>observer in observersForRegion) {
        if ([observer respondsToSelector:@selector(beaconManager:monitoringDidFailForRegion:withError:)]) {
            [observer beaconManager:self monitoringDidFailForRegion:(CLBeaconRegion *)region withError:error];
        }
    }
}



- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    NSPointerArray *observersForRegion = self.keyedObservers[beaconRegion.identifier];
    
    switch (state) {
        case CLRegionStateInside:
            for (id<MNBeaconManagerObserver>observer in observersForRegion) {
                if ([observer respondsToSelector:@selector(beaconManager:shouldAutoStartRangingBeaconsInRegion:)] &&
                    [observer beaconManager:self shouldAutoStartRangingBeaconsInRegion:beaconRegion]) {
                    [self.locationManager startRangingBeaconsInRegion:beaconRegion];
                }
            }
            break;
            
        case CLRegionStateOutside:
            break;
            
        case CLRegionStateUnknown:
            break;
    }
}



- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSPointerArray *observersForRegion = self.keyedObservers[region.identifier];
    
    for (id<MNBeaconManagerObserver>observer in observersForRegion) {
        if ([observer respondsToSelector:@selector(beaconManager:didRangeBeacons:inRegion:)]) {
            [observer beaconManager:self didRangeBeacons:beacons inRegion:region];
        }
    }
}


@end
