//
//  TwitterSearchManager.m
//  FishyMen
//
//  Created by Gene Crucean on 7/21/15.
//  Copyright (c) 2015 Dagger Dev. All rights reserved.
//

#import "TwitterSearchManager.h"
#import <AFNetworking/AFNetworking.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@implementation TwitterSearchManager


// Query some twitter hotness.
+ (void)queryTwitterWith:(NSDictionary *)query
{
    // Get account store and account type. For Twitter.
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Get Access Token from the big T.
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
    {
        if (granted)
        {
            // If successful, grab all accounts on the device.
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
             
             if (accounts.count > 0)
             {
                 // If the user has more than one account, use the first.
                 ACAccount *twitterAccount = [accounts objectAtIndex:0];
                 
                 // Send GET request to Twitter with passed in query params... which don't seem to be working all that great heh.
                 SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:ENDPOINT_TWITTER_TWEETS] parameters:query];
                 [twitterInfoRequest setAccount:twitterAccount];
                 [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                  {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          if (responseData)
                          {
                              // Serialize into JSON and dump into Array for later.
                              NSError *error = nil;
                              NSDictionary *resultDataDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                              NSArray *statuses = [resultDataDict objectForKey:@"statuses"];
                              
                              // Notify all observers to reload with the goods.
                              [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_TWITTER_QUERY_SUCCESSFUL object:nil userInfo:@{@"statuses": statuses}];
                          }
                      });
                  }];
             }
             else
             {
                 // BONGGGGG!!!
                 NSLog(@"No access");
                 [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_TWITTER_QUERY_FAILED object:nil userInfo:@{@"status": @"Please sign into twitter on your device in settings."}];
             }
         }
    }];
}




@end
