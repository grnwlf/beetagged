//
//  ViewController.m
//  Bees Chest
//
//  Created by Billy Irwin on 12/29/13.
//  Copyright (c) 2013 Arbrr. All rights reserved.
//

#import "ViewController.h"
#import "LIALinkedInApplication.h"
#import "LIALinkedInHttpClient.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.ancientprogramming.com"
                                                                                    clientId:@"clientId"
                                                                                clientSecret:@"clientSecret"
                                                                                       state:@"DCEEFWF45453sdffef424"
                                                                               grantedAccess:@[@"r_fullprofile", @"r_network"]];
    LIALinkedInHttpClient *client = [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
