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
@interface RCFacebookManager ()
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccount *account;
@end

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



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)userID {
    return [[self.account valueForKeyPath:@"properties.uid"] copy];
}



- (BOOL)userLoggedIn {
    return (self.account != nil);
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Facebook Graph
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loginWithCompletion:(void (^)(BOOL))complete {
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:@{ACFacebookAppIdKey:@"819312108084028",
                                                         ACFacebookPermissionsKey:@[@"user_birthday", @"email"],
                                                         ACFacebookAudienceKey: ACFacebookAudienceOnlyMe}
                                            completion:^(BOOL granted, NSError *error){
                                                
                                                if (granted) {
                                                      self.account = [self.accountStore accountsWithAccountType:accountType].firstObject;
                                                }
                                                else {
                                                    NSLog(@"Facebook login error: %@", error.description);
                                                }
                                                complete(granted);
                                            }
     ];
}



- (void)GET:(NSString *)endPoint
 parameters:(NSDictionary *)parameters
    success:(void (^)(id responseObject))success
    failure:(void (^)(NSError *error))failure{

    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", RCFBGraphAPI, endPoint]];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                            requestMethod:SLRequestMethodGET
                                                      URL:URL
                                               parameters:parameters];
    request.account = self.account;
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (!error) {
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseData
                                                                 options:NSJSONReadingAllowFragments
                                                                   error: &error];

            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(JSON);
                });
            }
        }
    }];
}
@end
