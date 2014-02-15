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
#import <FontAwesomeKit/FAKZocial.h>
#import "ContactsViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
//    if ([[FBManager singleton] loggedIn]) {
//        [self performSegueWithIdentifier:kLoginSegue sender:self];
//    }
    [FBManager singleton].vc = self;
    FAKZocial *fb = [FAKZocial facebookIconWithSize:15];
    UIImage *fbImage = [fb imageWithSize:CGSizeMake(300, 50)];
    [self.loginBtn setImage:fbImage forState:UIControlStateNormal];
    
    self.loginBtn.alpha = 1;
    
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)setProgress:(float)value {
    [self.progressView setProgress:value animated:YES];
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
//    [PFUser logOut];
    self.title = @"Facebook Profile";
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self loginToApp];
    }
}


#pragma mark - Login mehtods

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender  {
    NSLog(@"go");
   // [self startActivity];
    
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me",
                                   @"user_relationships",
                                   @"user_birthday",
                                   @"user_location",
                                   @"friends_about_me",
                                    @"friends_birthday",
                                   @"friends_education_history",
                                   @"friends_hometown",
                                   @"friends_likes",
                                   @"friends_relationship_details",
                                   @"friends_relationships",
                                   @"friends_website",
                                   @"friends_work_history" ];
    
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
            [self setFBId];
        } else {
            NSLog(@"User with facebook logged in!");
            [[FBManager singleton] cacheParseUser:user reformat:NO];
            [self fetchFriendsFromParse:0];
        }
    }];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

- (void)setFBId {
    FBRequest *fbrequest = [FBRequest requestForMe];
    
    [fbrequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        //        if (!error) {
        // result is a dictionary with the user's Facebook data
        NSLog(@"got me");
        NSMutableDictionary *userData = [(NSDictionary *)result mutableCopy];
        [userData removeObjectForKey:kContactHometown];
    
        NSString *fbid = userData[@"id"];
        [[PFUser currentUser] setValuesForKeysWithDictionary:userData];
        [[PFUser currentUser] setObject:fbid forKey:@"fbId"];
        [[PFUser currentUser] saveInBackground];
        
        [[FBManager singleton] cacheParseUser:[PFUser currentUser] reformat:YES];
        
//        PFObject *userModel = [PFObject objectWithClassName:@"UserModel"];
//        [userModel setValuesForKeysWithDictionary:userData];
//        [userModel setValue:fbid forKey:@"fbId"];
//        [userModel saveInBackground];
        [self fetchFBFriends];
    }];

}

- (void)fetchFriendsFromParse:(int)skip {
    PFQuery *query = [PFQuery queryWithClassName:@"UserModel"];
    [query setLimit:1000];
    [query setSkip:skip];
    [query whereKey:@"objectId" containedIn:[[PFUser currentUser] objectForKey:@"connections"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *o in objects) {
            Contact *c = [Contact contactFromUserModel:o];
        }
        [[[FBManager singleton] managedObjectContext] save:nil];
        if (objects.count < 1000) {
            [self createTmpUserDict];
        } else {
            [self fetchFriendsFromParse:skip+1000];
        }
        
        
    }];
    
}

- (void)createTmpUserDict {
    self.tmpUserDict = [[NSMutableDictionary alloc] init];
    [[FBManager singleton] fetchContacts];
    for (Contact *c in [FBManager singleton].fetchedResultsController.fetchedObjects) {
        c.tags_ = [[NSMutableDictionary alloc] init];
        self.tmpUserDict[c.fbId] = c;
    }
    NSLog(@"tmp dict size: %i", self.tmpUserDict.count);
    [self fetchTags:0];
}

- (void)fetchTags:(int)skip {
    NSLog(@"fetching tags");
    PFQuery *query = [PFQuery queryWithClassName:@"Tag"];
    [query setLimit:1000];
    [query setSkip:skip];
    [query whereKey:@"taggedBy" equalTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *o in objects) {
            Tag *t = [Tag tagFromParse:o];
            Contact *c = self.tmpUserDict[t.tagUserId];
            //NSLog(@"%@ %@", c.name, t.attributeName);
            [c.tags_ setObject:t forKey:t.attributeName];
        }
        
        [[[FBManager singleton] managedObjectContext] save:nil];
        if (objects.count < 1000) {
            [[FBManager singleton] fetchContacts];
            [self loginToApp];
        } else {
            [self fetchTags:skip+1000];
        }
        
        
    }];

}

- (void)fetchFBFriends
{
    FBRequest *friends = [FBRequest requestForGraphPath:@"me/friends?fields=about,bio,birthday,education,email,first_name,gender,id,hometown,last_name,name,relationship_status,work"];
    //FBRequest *friends = [FBRequest requestForGraphPath:@"me/friends"];
    [friends startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            NSLog(@"error fetching friends %@", error);
            [PFUser logOut];
            //should logout user and have them restart
        } else {
            NSLog(@"friends: %@", result[@"data"]);
            [[FBManager singleton] importContacts:result[@"data"] cb:^(void) {
               [self loginToApp];
            }];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //override any actions before pushing
}

- (void)loginToApp {
    [self performSegueWithIdentifier:kLoginSegue sender:self];
}




@end
