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
#import "BATypeAheadViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
//    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.ancientprogramming.com"
//                                                                                    clientId:@"clientId"
//                                                                                clientSecret:@"clientSecret"
//                                                                                       state:@"DCEEFWF45453sdffef424"
//                                                                               grantedAccess:@[@"r_fullprofile", @"r_network"]];
//    LIALinkedInHttpClient *client = [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
    
    NSArray *data = @[@"developer", @"designer", @"math", @"coding", @"chris", @"Billy", @"entrepeneur", @"dealer"];
    
    self.b = [[BATypeAheadViewController alloc] initWithFrame:CGRectMake(0, 0, kWidth, 300) andData:data];
    self.b.delegate = self;
    //[self.view addSubview:self.b.view];
    
	// Do any additional setup after loading the view, typically from a nib.
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

- (IBAction)login:(id)sender
{
    [self performSegueWithIdentifier:kLoginSegue sender:self];
}

@end
