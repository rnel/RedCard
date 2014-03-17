//
//  RCFacebookManager.h
//  RedCard
//
//  Created by Ronnie Liew on 13/3/14.
//  Copyright (c) 2014 Monokromik. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Accounts;

@interface RCFacebookManager : NSObject

@property (nonatomic, copy, readonly) NSString *userID;
@property (nonatomic, assign, readonly) BOOL userLoggedIn;
- (void)loginWithCompletion:(void (^)(BOOL success))complete;
- (void)GET:(NSString *)endPoint parameters:(NSDictionary *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
@end
