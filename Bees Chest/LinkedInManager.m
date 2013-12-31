//
//  LinkedInManager.m
//  Bees Chest
//
//  Created by Billy Irwin on 12/29/13.
//  Copyright (c) 2013 Arbrr. All rights reserved.
//

#import "LinkedInManager.h"
#import "Constants.h"

@implementation LinkedInManager

static LinkedInManager *li = nil;

+ (LinkedInManager*)singleton
{
    if (!li) {
        li = [[LinkedInManager alloc] init];
    }
    return li;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.liApp = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.ancientprogramming.com"
                                                                                        clientId:kLinkedInAPIKey
                                                                                    clientSecret:kLinkedInSecretKey
                                                                                           state:@"DCEEFWF45453sdffef424"
                                                                                   grantedAccess:@[@"r_fullprofile", @"r_network"]];
        self.liClient = [LIALinkedInHttpClient clientForApplication:self.liApp presentingViewController:nil];
    }
    return self;
}



@end
