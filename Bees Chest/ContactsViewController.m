//
//  ContactsViewController.m
//  Bees Chest
//
//  Created by Billy Irwin on 1/1/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import "ContactsViewController.h"
#import "Contact.h"

@interface ContactsViewController ()

@end

#define kCellHeight 60

@implementation ContactsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.ContactTableView.delegate = self;
    self.ContactTableView.dataSource = self;
    [self.ContactTableView reloadData];
    
    self.navigationController.navigationBar.hidden = YES;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"showing contacts view");
    [self.ContactTableView reloadData];
    self.navigationController.navigationBar.hidden = YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    int x = [[[LinkedInManager singleton] getContacts] count];
    NSLog(@"%i", x);
    return x;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:kContactCell forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kContactCell];
    }
    
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    Contact *c = [[[LinkedInManager singleton] getContacts] objectAtIndex:indexPath.row];
    label.text = [NSString stringWithFormat:@"%@ %@", c.firstName, c.lastName];
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:2];
    imageView.image = c.profileImage;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:kShowContactSegue sender:self];
}

@end
