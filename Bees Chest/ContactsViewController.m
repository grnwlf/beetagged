//
//  ContactsViewController.m
//  Bees Chest
//
//  Created by Billy Irwin on 1/1/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import "ContactsViewController.h"
#import "Contact.h"
#import "TagCell.h"
#import "UIColor+Bee.h"

@interface ContactsViewController ()

@end

@implementation ContactsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
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
    self.ContactTableView.sectionIndexColor = [UIColor goldBeeColor];
    [self.ContactTableView reloadData];
    
    self.searchBar.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO; // make sure we can't swipe to logout
    self.tagFilterView.backgroundColor = [UIColor cloudsColor];
    
    // customize the beeButton
    [self.beeButton setBackgroundColor:[UIColor goldBeeColor]];
    self.beeButton.layer.cornerRadius = 2.0;
    self.beeButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    [self.beeButton addTarget:self action:@selector(newTag:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tagTableView.backgroundColor = [UIColor clearColor];
    self.tagTableView.delegate = self;
    self.tagTableView.dataSource = self;
    
    [self.view addSubview:self.tagFilterView];

    self.tagFilters = [[NSMutableArray alloc] init];
    self.searchBar.tintColor = [UIColor goldBeeColor];
    
    [self typeahead];
}

- (void)typeahead {
    float top = 70.0, left = 20.0, height = 180.0;
    self.typeAheadViewController = [[BATypeAheadViewController alloc] initWithFrame:CGRectMake(left, top, 180, height) andData:[[FBManager singleton] tagOptionsArray]];
    self.typeAheadViewController.delegate = self;
    self.typeAheadViewController.view.layer.cornerRadius = 10.0;
    self.typeAheadViewController.view.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:240.0/255.0 blue:241.0/255.0 alpha:.95];
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

- (IBAction)removeTag:(UIButton *)sender {
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview.superview;
    while (cell && [cell class] == [UITableViewCell class]) {
        cell = (UITableViewCell *)cell.superview;
    }
    
    NSIndexPath *indexPathForCell = [self.tagTableView indexPathForCell:cell];
    [self.tagFilters removeObjectAtIndex:indexPathForCell.row];
    [self.tagTableView reloadData];
    [self renderFilter];
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
        
        UILabel *homeLabel = (UILabel *)[cell viewWithTag:3];
        homeLabel.text = contact.hometown;
        
        UILabel *workLabel = (UILabel *)[cell viewWithTag:4];
        if (contact.work.count > 0) {
            NSDictionary *d = contact.work[0];
            workLabel.text = [NSString stringWithFormat:@"%@", d[kContactEmployer]];
        } else {
            workLabel.text = nil;
        }
        
        UILabel *schoolLabel = (UILabel *)[cell viewWithTag:4];
        if (contact.education.count > 0) {
            NSDictionary *d = contact.education[0];
            schoolLabel.text = [NSString stringWithFormat:@"%@", d[kContactSchool]];
        } else {
            schoolLabel.text = nil;
        }
        
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:2];
        [imageView setImageWithURL:[NSURL URLWithString:contact.pictureUrl] placeholderImage:kContactCellPlaceholderImage];
        
        return cell;
    } else if (tableView == self.tagTableView) {
        static NSString *tagCellIdentifier = @"TagFilterCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tagCellIdentifier forIndexPath:indexPath];
        

        cell.textLabel.text = @"";
        UILabel *label = (UILabel *)[cell viewWithTag:2];
        label.text = self.tagFilters[indexPath.row];
        
        UIButton *button = (UIButton *)[cell viewWithTag:1];
        [button setTintColor:[UIColor redColor]];
        [button addTarget:self action:@selector(removeTag:) forControlEvents:UIControlEventTouchUpInside];
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
    }
    return nil;
}

- (void)setIndexTitlesColor {
    for (UIView *view in [self.tagTableView subviews]) {
        if([[[view class] description] isEqualToString:@"UITableViewIndex"]) {
            [view setBackgroundColor:[UIColor goldBeeColor]];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.ContactTableView) {
        [self performSegueWithIdentifier:kShowContactSegue sender:self];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (tableView == self.tagTableView) {
        [self.tagFilters removeObjectAtIndex:indexPath.row];
        [self renderFilter];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kShowContactSegue]) {
        FBManager *lim = [FBManager singleton];
         NSIndexPath *indexPath = [self.ContactTableView indexPathForSelectedRow];
        Contact *contact;
        if (lim.search) {
            contact = [lim.searchArray objectAtIndex:indexPath.row];
        } else if (lim.tagFilter) {
            contact = [[lim.filterArray objectAtIndex:indexPath.row] objectForKey:@"contact"];
        } else {
            contact = [lim.fetchedResultsController objectAtIndexPath:indexPath];
        }
        ContactViewController *cvc = (ContactViewController *)[segue destinationViewController];
        cvc.isCurrentUser = NO;
        [cvc renderContact:contact];
    }
}
- (IBAction)filterTags:(id)sender {
    if (!self.typeAheadViewController.data) {
        self.typeAheadViewController.data = [[FBManager singleton] tagOptionsArray];
    }
    if (self.tagFilterView.frame.origin.x > 300) {
        [UIView animateWithDuration:0.5 animations:^{
            self.tagFilterView.frame = CGRectMake(100, 64, 220, kHeight-100);
        }];
    } else {
        [self.typeAheadViewController hideView:YES];
        [UIView animateWithDuration:0.5 animations:^{
            self.tagFilterView.frame = CGRectMake(320, 64, 220, kHeight-100);
        }];
    }
}

- (void)cellClickedWithData:(id)data {
    TagOption *t = (TagOption*)data;
    [self.tagFilters addObject:t.attributeName];
    [self.typeAheadViewController hideView:YES];
    [self.tagTableView reloadData];
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

//- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
//    return self.tagFilters.count;
//}

//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
////    // if it's the last item, you can select it
////    if (indexPath.item == self.contactTags.count) {
////        return YES;
////    } else if (indexPath.item == self.itemToDelete) {
////        return YES;
////    }
//    NSLog(@"can touch");
//    return YES;
//}

// called when the item is selected - will only do anything if the add button
// is selected
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    //[collectionView deselectItemAtIndexPath:indexPath animated:YES];
//    // if it's the last item, add a new item
//    [self.tagFilters removeObjectAtIndex:indexPath.item];
//    [self.tagCollectionView reloadData];
//    
//    [[FBManager singleton] filterForTags:self.tagFilters];
//    
//    [self.ContactTableView reloadData];
//}
//
//- (void)clearDeleteViewAtIndex:(NSInteger)index {
//    //    self.itemToDelete = -1;
//    //    [UIView animateWithDuration:.3 animations:^{
//    //        [self.tagsCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0], [NSIndexPath indexPathForItem:self.contactTags.count inSection:0]]];
//    //    }];
//}




// style the collectionView cell at the indexPath
//- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *tagCellIdentifier = @"TagCell";
//    [self.tagCollectionView registerClass:[TagCell class] forCellWithReuseIdentifier:tagCellIdentifier];
//    
//    TagCell *cell = (TagCell *)[cv dequeueReusableCellWithReuseIdentifier:tagCellIdentifier forIndexPath:indexPath];
//    //UILabel *label = (UILabel *)[cell viewWithTag:1];
//    UILabel *label = [[UILabel alloc] init];
//    NSInteger i = indexPath.item;
//    cell.layer.cornerRadius = cell.frame.size.height / 4;
//    cell.itemIndex = i;
//    cell.delegate = self;
//    
//
//        if (i < self.tagFilters.count) {
//            [cell addLongPress];
//            NSString *tag = self.tagFilters[i];
//            NSLog(@"got tag %@", tag);
//            [label setText:tag];
//            label.textColor = [UIColor whiteColor];
//        }
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Helvetica-Bold" size:20.0], NSFontAttributeName, nil];
//    if (indexPath.item >= self.tagFilters.count) {
//        [label setFrame:CGRectMake(0, 0, 50, 50)];
//    } else {
//        CGSize s = CGSizeMake([self.tagFilters[indexPath.item] sizeWithAttributes:attributes].width, 50);
//        [label setFrame:CGRectMake(0, 0, s.width, s.height)];
//    }
//    [label setTextColor:[UIColor blackColor]];
//    label.textAlignment = NSTextAlignmentCenter;
//    [cell.contentView addSubview:label];
//    
//    NSLog(@"%@", label.text);
//    
//    return cell;
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Helvetica-Bold" size:20.0], NSFontAttributeName, nil];
//    CGSize s = CGSizeMake([self.tagFilters[indexPath.item] sizeWithAttributes:attributes].width, 50);
//    return s;
//}

@end
