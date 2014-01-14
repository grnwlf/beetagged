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
    FBManager *lim = [FBManager singleton];
    if (!lim.hasContacts) {
        [lim refreshContacts];
    }
    [self.ContactTableView reloadData];
    
    self.navigationController.navigationBar.hidden = YES;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.ContactTableView reloadData];
    self.navigationController.navigationBar.hidden = YES;
}


#pragma mark - Table view data source

// returns the number of groupings in the table view if the user is not searching,
// but returns 1 if the user is searching
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 1;
    FBManager *lim = [FBManager singleton];
    if (!lim.isSearching) {
        numberOfSections = [lim.fetchedResultsController.sections count];
    }
    return numberOfSections;
}

// returns the number of rows in the given section based on whether or not
// we are searching or not.
-(NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    FBManager *lim = [FBManager singleton];
    NSInteger numberOfRows = 0;
    if (lim.isSearching) {
        numberOfRows = lim.searchArray.count;
    } else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[lim.fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
}

// returns the title for the header in the section. It will not give a header
// (because title is nil) if the tableView is searching
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    FBManager *lim = [FBManager singleton];
    NSString *title = nil;
    
    if (!lim.isSearching &&  [[lim.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[lim.fetchedResultsController sections] objectAtIndex:section];
        title = [sectionInfo name];
    }
    return title;
}

// shows the sectionIndexTitles if the tableView is grouped.
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    FBManager *lim = [FBManager singleton];
    NSArray *sectionIndexTitles = nil;
    if (!lim.isSearching) {
        sectionIndexTitles = [lim.fetchedResultsController sectionIndexTitles];
    }
    return sectionIndexTitles;
}

// tells the tableView which section to jump to when the index side bar is clicked.
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    FBManager *lim = [FBManager singleton];
    NSInteger section = 0;
    if (!lim.isSearching) {
        section = [lim.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
    }
    return section;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:kContactCell forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kContactCell];
    }
    FBManager *lim = [FBManager singleton];
    Contact *contact = [lim.fetchedResultsController objectAtIndexPath:indexPath];
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:1];
    nameLabel.text = [NSString stringWithFormat:@"%@ %@", contact.first_name, contact.last_name];
    
    UILabel *industryLabel = (UILabel *)[cell viewWithTag:3];
    industryLabel.text = contact.industry;
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:2];
    [imageView setImageWithURL:[NSURL URLWithString:contact.pictureUrl] placeholderImage:kContactCellPlaceholderImage];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:kShowContactSegue sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kShowContactSegue]) {
        FBManager *lim = [FBManager singleton];
        NSIndexPath *indexPath = [self.ContactTableView indexPathForSelectedRow];
        Contact *contact = [lim.fetchedResultsController objectAtIndexPath:indexPath];
        ContactViewController *cvc = (ContactViewController *)[segue destinationViewController];
        [cvc setContact:contact];
    }
}
@end
