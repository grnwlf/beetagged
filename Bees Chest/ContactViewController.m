//
//  ContactViewController.m
//  Bees Chest
//
//  Created by Billy Irwin on 1/1/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import "ContactViewController.h"

@interface ContactViewController ()

@end

@implementation ContactViewController

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
    // remove all of the autolayout contraints because the fuck everything up
    [self.view removeConstraints:self.view.constraints];
    
    // 1. set the image
	[self.contactImage setImageWithURL:[NSURL URLWithString:self.contact.pictureUrl] placeholderImage:kContactCellPlaceholderImage];
    
    // 2.set the Contact name
    self.nameLabel.text = self.contact.formattedName;
    
    // 3. set the Contact's job title and the Contact's position title
    if (self.contact.positionTitle && self.contact.positionTitle.length > 0 && self.contact.positionName && self.contact.positionName.length > 0) {
        self.companyLabel.text = [NSString stringWithFormat:@"at %@",self.contact.positionName];
        self.titleLabel.text = self.contact.positionTitle;
    } else if (self.contact.positionTitle && self.contact.positionTitle.length > 0) {
        self.companyLabel.text = @"";
        self.titleLabel.text = self.contact.positionTitle;
        float moveBy = 10.0;
        
        // 1. move the name label down
        CGRect f = self.nameLabel.frame;
        [self.nameLabel setFrame:CGRectMake(f.origin.x, f.origin.y + moveBy, f.size.width, f.size.height)];
        
        // 2. move the position label down
        f = self.titleLabel.frame;
        [self.titleLabel setFrame:CGRectMake(f.origin.x, f.origin.y + moveBy, f.size.width, f.size.height)];
        
        // 3. move the button up
        f = self.goToLinkedInButton.frame;
        [self.goToLinkedInButton setFrame:CGRectMake(f.origin.x, f.origin.y - moveBy, f.size.width, f.size.height)];


    } else {
        self.companyLabel.text = @"";
        self.titleLabel.text = @"";
        
        float moveBy = 30.0;
        // 1. move the name label down
        CGRect f = self.nameLabel.frame;
        [self.nameLabel setFrame:CGRectMake(f.origin.x, f.origin.y + moveBy, f.size.width, f.size.height)];
        
        // 2. move the button up
        f = self.goToLinkedInButton.frame;
        [self.goToLinkedInButton setFrame:CGRectMake(f.origin.x, f.origin.y - moveBy, f.size.width, f.size.height)];
    }
    self.goToLinkedInButton.backgroundColor = [UIColor yellowColor]; // starfish make a better color
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"contact view did appear");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"showing contact view");
    self.navigationController.navigationBar.hidden = NO;
}

// function that opens the linkedIn profile
- (void)goToLinkedIn {
    NSLog(@"Implement go to linkedIn!!!");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
