//
//  ContactsViewController.h
//  Bees Chest
//
//  Created by Billy Irwin on 1/1/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BATypeAheadViewController.h"
#import "BeeButton.h"
@interface ContactsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIActionSheetDelegate, BATypeAheadDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UITableView *ContactTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet BeeButton *beeButton;

@property (strong, nonatomic) IBOutlet UIView *tagFilterView;
@property (strong, nonatomic) BATypeAheadViewController *typeAheadViewController;

@property (strong, nonatomic) IBOutlet UITableView *tagTableView;
@property (strong, nonatomic) NSMutableArray *tagFilters;

- (IBAction)filterTags:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)newTag:(id)sender;

@end
