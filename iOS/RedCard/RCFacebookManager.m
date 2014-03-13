//
//  RCFacebookManager.m
//  RedCard
//
//  Created by Ronnie Liew on 13/3/14.
//  Copyright (c) 2014 Monokromik. All rights reserved.
//


@import Social;
#import "RCFacebookManager.h"

NSString * const RCFBGraphAPI = @"https://graph.facebook.com/";


@implementation RCFacebookManager
- (instancetype)init {
    self = [super init];
    if (self) {
        self.accountStore = [[ACAccountStore alloc] init];
        ACAccountType *facebookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        self.account = [self.accountStore accountsWithAccountType:facebookAccountType].firstObject;
        
        
    }
    return self;
}


- (void)GET:(NSString *)endPoint parameters:(NSDictionary *)parameters {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", RCFBGraphAPI, endPoint]];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                            requestMethod:SLRequestMethodGET
                                                      URL:URL
                                               parameters:parameters];
    request.account = self.account;
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (!error) {
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseData options: NSJSONReadingAllowFragments error: &error];
            NSLog(@"Request %@", JSON);
        }
    }];
}
@end
