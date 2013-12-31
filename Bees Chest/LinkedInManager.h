//
//  LinkedInManager.h
//  Bees Chest
//
//  Created by Billy Irwin on 12/29/13.
//  Copyright (c) 2013 Arbrr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LIALinkedInApplication.h>
#import <LIALinkedInHttpClient.h>

@interface LinkedInManager : NSObject
@property (strong, nonatomic) LIALinkedInApplication *liApp;
@property (strong, nonatomic) LIALinkedInHttpClient *liClient;

+ (LinkedInManager*)singleton;

@end
