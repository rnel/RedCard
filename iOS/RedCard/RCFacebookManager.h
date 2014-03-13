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
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccount *account;
- (void)GET:(NSString *)endPoint parameters:(NSDictionary *)parameters;
@end
