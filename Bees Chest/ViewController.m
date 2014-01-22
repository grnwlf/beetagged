//
//  ViewController.m
//  Bees Chest
//
//  Created by Billy Irwin on 12/29/13.
//  Copyright (c) 2013 Arbrr. All rights reserved.
//

#import "ViewController.h"
#import "FBManager.h"
#import "BATypeAheadViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
//    if ([[FBManager singleton] loggedIn]) {
//        [self performSegueWithIdentifier:kLoginSegue sender:self];
//    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (IBAction)login:(id)sender {
//    [self performSegueWithIdentifier:kLoginSegue sender:self];
//}
//
//- (IBAction)loginWithLinkedIn:(id)sender {
//    FBManager *li = [FBManager singleton];
//    
//    // Get the authorization code.
//    [li.client getAuthorizationCode:^(NSString * code) {
//        
//        // the the access token
//        [li.client getAccessToken:code success:^(NSDictionary *accessTokenData) {
//            NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
//            [li setToken:accessToken];
//            
//            // Get the current user
//            [li.client getPath:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~:(id,first-name,last-name,formatted-name,headline,location,industry,positions,picture-url,site-standard-profile-request)?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation * operation, NSDictionary *result) {
//
//                    // Set the current user
//                    [li setCurrentUser:result];
//                
//                    // Save the current user to Parse
//                    // starfish - make sure that you create a user here.
////                    NSLog(@"current user %@", result);
//                
//                    // get the connections
//                    [li.client getPath:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~/connections:(id,first-name,last-name,formatted-name,headline,location,industry,positions,picture-url,site-standard-profile-request)?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation * operation, NSDictionary *result) {
////                    NSLog(@"connections %@", result);
//                        
//                        // Import all of the contacts
//                        [[FBManager singleton] importContacts:result[@"values"]];
//                        
//                        // Go to the next view.
//                        [self performSegueWithIdentifier:kLoginSegue sender:self];
//                } failure:^(AFHTTPRequestOperation * operation, NSError *error) {
//                    NSLog(@"failed to fetch current user %@", error);
//                }];
//            } failure:^(AFHTTPRequestOperation * operation, NSError *error) {
//                NSLog(@"failed to fetch current user %@", error);
//            }];
//        } failure:^(NSError *error) {
//            NSLog(@"Quering accessToken failed %@", error);
//        }];
//    } cancel:^{
//        NSLog(@"Authorization was cancelled by user");
//    } failure:^(NSError *error) {
//        NSLog(@"Authorization failed %@", error);
//    }];
//
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Facebook Profile";
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self loginToApp];
    }
}


#pragma mark - Login mehtods

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self fetchFBFriends];
        } else {
            NSLog(@"User with facebook logged in!");
            [self fetchFBFriends];
        }
    }];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

- (void)fetchFBFriends
{
    FBRequest *friends = [FBRequest requestForMyFriends];
    [friends startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            NSLog(@"error");
            [PFUser logOut];
            //should logout user and have them restart
        } else {
            NSLog(@"friends: %@", result);
            [[FBManager singleton] importContacts:result[@"data"]];
            [self loginToApp];
        }
    }];
}

- (void)loginToApp {
    [self performSegueWithIdentifier:kLoginSegue sender:self];
}




@end
