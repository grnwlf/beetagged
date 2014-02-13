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
    self.ContactTableView.clipsToBounds = YES;
    [self.ContactTableView reloadData];
    
    self.searchBar.delegate = self;
    
    self.tagFilterView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, kWidth, kHeight-60)];
    self.tagFilterView.backgroundColor = [UIColor whiteColor];
    self.tagFilterView.alpha = 0;
    
    [self.view addSubview:self.tagFilterView];
    self.tagFilterTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, kWidth, kHeight-150)];
    self.tagFilterTableView.delegate = self;
    self.tagFilterTableView.dataSource = self;
    [self.tagFilterView addSubview:self.tagFilterTableView];
    
    UIButton *newTag = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kWidth, 40)];
    [newTag setTitle:@"New Tag" forState:UIControlStateNormal];
    [newTag setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.tagFilterView addSubview:newTag];
    [newTag addTarget:self action:@selector(newTag:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tagFilters = [[NSMutableArray alloc] init];
    [self typeahead];
    
    //self.navigationController.navigationBar.hidden = YES;
	// Do any additional setup after loading the view.
}

- (void)typeahead {
    float top = 70.0, left = 20.0, height = 180.0;
    
    self.typeAheadViewController = [[BATypeAheadViewController alloc] initWithFrame:CGRectMake(left, top, self.view.frame.size.width - left * 2, height) andData:[[FBManager singleton] tagOptionsArray]];
    self.typeAheadViewController.delegate = self;
    self.typeAheadViewController.view.layer.cornerRadius = 40.0;
    self.typeAheadViewController.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.6];
    self.typeAheadViewController.view.tableView.backgroundColor = [UIColor clearColor];
    [self.typeAheadViewController hideView:NO];
    [self addChildViewController:self.typeAheadViewController];
    self.typeAheadViewController.delegate = self;
    [self.tagFilterView addSubview:self.typeAheadViewController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        [[FBManager singleton] search:@""];
        [self.ContactTableView reloadData];
        
    }
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSLog(@"%@", text);
    NSString *query = [NSString stringWithFormat:@"%@%@", searchBar.text, text];
    if ([text isEqualToString:@""]) {
        NSLog(@"backspace");
        query = [query substringToIndex:query.length-1];
    } else if ([text isEqualToString:@"\n"]) {
        // Search Pressed
        [searchBar resignFirstResponder];
        return NO;
    }
    query = [query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"%@", query);
    [[FBManager singleton] search:query];
    [self.ContactTableView reloadData];
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = ![searchBar.text isEqualToString:@""];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    
    [searchBar resignFirstResponder];
    [[FBManager singleton] search:@""];
    [self.ContactTableView reloadData];
}


#pragma mark - Table view data source

// returns the number of groupings in the table view if the user is not searching,
// but returns 1 if the user is searching
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.ContactTableView) {
        NSInteger numberOfSections = 1;
        FBManager *lim = [FBManager singleton];
        if (!lim.search && !lim.tagFilter) {
            numberOfSections = [lim.fetchedResultsController.sections count];
        }
        return numberOfSections;
    }
    return 1;
}

// returns the number of rows in the given section based on whether or not
// we are searching or not.
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.ContactTableView) {
        FBManager *lim = [FBManager singleton];
        NSInteger numberOfRows = 0;
        if (lim.search) {
            numberOfRows = lim.searchArray.count;
        } else if (lim.tagFilter) {
            numberOfRows = lim.filterArray.count;
        } else {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[lim.fetchedResultsController sections] objectAtIndex:section];
            numberOfRows = [sectionInfo numberOfObjects];
        }
        return numberOfRows;
    }
    return self.tagFilters.count;
}

// returns the title for the header in the section. It will not give a header
// (because title is nil) if the tableView is searching
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.ContactTableView) {
        FBManager *lim = [FBManager singleton];
        NSString *title = nil;
        
        if (!lim.search &&  [[lim.fetchedResultsController sections] count] > 0 && !lim.tagFilter) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[lim.fetchedResultsController sections] objectAtIndex:section];
            title = [sectionInfo name];
        }
        return title;
    }
    return @"";
}

// shows the sectionIndexTitles if the tableView is grouped.
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.ContactTableView) {
        FBManager *lim = [FBManager singleton];
        NSArray *sectionIndexTitles = nil;
        if (!lim.search && !lim.tagFilter) {
            sectionIndexTitles = [lim.fetchedResultsController sectionIndexTitles];
        }
        return sectionIndexTitles;
    }
    return @[];
}

// tells the tableView which section to jump to when the index side bar is clicked.
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView == self.ContactTableView) {
        FBManager *lim = [FBManager singleton];
        NSInteger section = 0;
        if (!lim.search && !lim.tagFilter) {
            section = [lim.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
        }
        return section;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.ContactTableView) {
        UITableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:kContactCell forIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kContactCell];
        }
        FBManager *lim = [FBManager singleton];
        Contact *contact;
        if (lim.search) {
            contact = [lim.searchArray objectAtIndex:indexPath.row];
        } else if (lim.tagFilter) {
            contact = [[lim.filterArray objectAtIndex:indexPath.row] objectForKey:@"contact"];
        } else {
            contact = [lim.fetchedResultsController objectAtIndexPath:indexPath];
        }
        
        UILabel *nameLabel = (UILabel*)[cell viewWithTag:1];
        nameLabel.text = [NSString stringWithFormat:@"%@ %@", contact.first_name, contact.last_name];
        
        UILabel *industryLabel = (UILabel *)[cell viewWithTag:3];
        industryLabel.text = contact.industry;
        
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:2];
        [imageView setImageWithURL:[NSURL URLWithString:contact.pictureUrl] placeholderImage:kContactCellPlaceholderImage];
        
        return cell;
    } else {
        NSString *t = self.tagFilters[indexPath.row];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TagFilterCell"];
        cell.textLabel.text = t;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.ContactTableView) {
        [self performSegueWithIdentifier:kShowContactSegue sender:self];
    } else {
        [self.tagFilters removeObjectAtIndex:indexPath.row];
        [self.tagFilterTableView reloadData];
        [self renderFilter];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kShowContactSegue]) {
        FBManager *lim = [FBManager singleton];
        NSIndexPath *indexPath = [self.ContactTableView indexPathForSelectedRow];
        Contact *contact = [lim.fetchedResultsController objectAtIndexPath:indexPath];
        ContactViewController *cvc = (ContactViewController *)[segue destinationViewController];
        [cvc renderContact:contact];
    }
}
- (IBAction)filterTags:(id)sender {
    if (!self.typeAheadViewController.data) {
        self.typeAheadViewController.data = [[FBManager singleton] tagOptionsArray];
    }
    if (self.tagFilterView.alpha > 0) {
        self.tagFilterView.alpha = 0;
        [self.typeAheadViewController hideView:YES];
    } else {
        self.tagFilterView.alpha = 1;
    }
}

- (void)cellClickedWithData:(id)data {
    TagOption *t = (TagOption*)data;
    [self.tagFilters addObject:t.attributeName];
    [self.tagFilterTableView reloadData];
    [self.typeAheadViewController hideView:YES];
    [self renderFilter];

}

- (void)renderFilter {
    NSLog(@"render tag filters");
    FBManager *fb = [FBManager singleton];
    fb.search = NO;
    fb.tagFilter = YES;
    [fb filterForTags:self.tagFilters];
    
    [self.ContactTableView reloadData];
}


- (IBAction)newTag:(id)sender {
    [self.typeAheadViewController showView:YES];
}

- (IBAction)logout:(id)sender {
    [[FBManager singleton] clearDB];
    [PFUser logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
