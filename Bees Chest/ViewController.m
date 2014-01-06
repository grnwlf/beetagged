//
//  ViewController.m
//  Bees Chest
//
//  Created by Billy Irwin on 12/29/13.
//  Copyright (c) 2013 Arbrr. All rights reserved.
//

#import "ViewController.h"
#import "LinkedInManager.h"
#import "BATypeAheadViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    NSArray *data = @[@"developer", @"designer", @"math", @"coding", @"chris", @"Billy", @"entrepeneur", @"dealer"];
    
    self.b = [[BATypeAheadViewController alloc] initWithFrame:CGRectMake(0, 0, kWidth, 300) andData:data];
    self.b.delegate = self;
    
    LinkedInManager *li = [LinkedInManager singleton];
    li.client = [LIALinkedInHttpClient clientForApplication:li.app presentingViewController:self];
    
    
    //[self.view addSubview:self.b.view];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([[LinkedInManager singleton] loggedIn]) {
        [self performSegueWithIdentifier:kLoginSegue sender:self];
    }
}

- (void)cellClickedWithData:(NSString *)data
{
    NSLog(@"chose %@", data);
    [self.b hideAndClearTableView];
    self.b.view.inputTextField.text = data;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    [self performSegueWithIdentifier:kLoginSegue sender:self];
}

- (IBAction)loginWithLinkedIn:(id)sender {
    LinkedInManager *li = [LinkedInManager singleton];
    
    // Get the authorization code.
    [li.client getAuthorizationCode:^(NSString * code) {
        
        // the the access token
        [li.client getAccessToken:code success:^(NSDictionary *accessTokenData) {
            NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
            [li setToken:accessToken];
            
            // Get the current user
            [li.client getPath:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~:(id,first-name,last-name,formatted-name,headline,location,industry,positions,picture-url,site-standard-profile-request)?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation * operation, NSDictionary *result) {

                    // Set the current user
                    [li setCurrentUser:result];
                
                    // Save the current user to Parse
                    // starfish - make sure that you create a user here.
//                    NSLog(@"current user %@", result);
                
                    // get the connections
                    [li.client getPath:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~/connections:(id,first-name,last-name,formatted-name,headline,location,industry,positions,picture-url,site-standard-profile-request)?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation * operation, NSDictionary *result) {
//                    NSLog(@"connections %@", result);
                        
                        // Import all of the contacts
                        [[LinkedInManager singleton] importContacts:result[@"values"]];
                        
                        // Go to the next view.
                        [self performSegueWithIdentifier:kLoginSegue sender:self];
                } failure:^(AFHTTPRequestOperation * operation, NSError *error) {
                    NSLog(@"failed to fetch current user %@", error);
                }];
            } failure:^(AFHTTPRequestOperation * operation, NSError *error) {
                NSLog(@"failed to fetch current user %@", error);
            }];
        } failure:^(NSError *error) {
            NSLog(@"Quering accessToken failed %@", error);
        }];
    } cancel:^{
        NSLog(@"Authorization was cancelled by user");
    } failure:^(NSError *error) {
        NSLog(@"Authorization failed %@", error);
    }];

}



@end
