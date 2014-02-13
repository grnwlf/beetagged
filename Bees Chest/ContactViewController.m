//
//  ContactViewController.m
//  Bees Chest
//
//  Created by Billy Irwin on 1/1/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import "ContactViewController.h"
#import "ProfileDetailCell.h"

@interface ContactViewController ()

@property (nonatomic, strong) NSMutableArray *deleted;
@property (nonatomic, strong) NSMutableArray *added;
@property (nonatomic, assign) NSInteger itemToDelete;

@end

@implementation ContactViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark View Loading
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tagsCollectionView.delegate = self;
    self.tagsCollectionView.dataSource = self;
    self.tagsCollectionView.backgroundColor = [UIColor clearColor];
    
    self.expandedRows = [[NSMutableDictionary alloc] init];
    
    [self formatLayout];
    [self typeahead];
    self.deleted = [@[] mutableCopy];
    self.added = [@[] mutableCopy];
    self.itemToDelete = -1;
    self.contactTags = [[self.contact.tags_ allValues] mutableCopy];
}

- (void)renderContact:(Contact*)c {
    self.contact = c;
    [self.profileTableView reloadData];
}

// style the typeahead view
- (void)typeahead {
    float top = 70.0, left = 20.0, height = 180.0;

    self.typeAheadViewController = [[BATypeAheadViewController alloc] initWithFrame:CGRectMake(left, top, self.view.frame.size.width - left * 2, height) andData:[[FBManager singleton] tagOptionsArray]];
    self.typeAheadViewController.delegate = self;
    self.typeAheadViewController.view.layer.cornerRadius = 40.0;
    self.typeAheadViewController.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.6];
    self.typeAheadViewController.view.tableView.backgroundColor = [UIColor clearColor];
    [self.typeAheadViewController hideView:NO];
    [self addChildViewController:self.typeAheadViewController];
    [self.view addSubview:self.typeAheadViewController.view];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

// save the data to parse before we leave
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
  //  [self updateAddedTagsInParse];
    [self updatedDeletedTagsInParse];
}


#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contact.profileAttributeKeys.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) return 200;
    else {
        NSString *key = self.contact.profileAttributeKeys[indexPath.row-1];
        if (self.expandedRows[key]) return [self.contact detailAttributesFor:key].count * 40 + 50;
        else return 50;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kProfileHeaderCell forIndexPath:indexPath];
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
        [imageView setImageWithURL:[NSURL URLWithString:self.contact.pictureUrl]];
        
        UILabel *label = (UILabel*)[cell viewWithTag:2];
        label.text = [self.contact name];
        
        return cell;
    } else {
        ProfileDetailCell *cell = (ProfileDetailCell*)[tableView dequeueReusableCellWithIdentifier:kProfileDetailCell forIndexPath:indexPath];
        if (cell.textFields) {
            for (UITextField *t in cell.textFields) {
                [t removeFromSuperview];
            }
        } else {
            cell.textFields = [[NSMutableArray alloc] init];
        }
        
        NSMutableArray *detail = [self.contact detailAttributesFor:self.contact.profileAttributeKeys[indexPath.row-1]];
        
        UILabel *l = (UILabel*)[cell viewWithTag:1];
        l.text = detail[0];
        
        float h = 50;
        for (int i = 1; i < detail.count; i++) {
            NSDictionary *d = detail[i];
            
            if ([detail[0] isEqualToString:kContactBio]) {
                UITextField *t = [[UITextField alloc] initWithFrame:CGRectMake(30, h, kWidth-60, 40)];
                t.text = [NSString stringWithFormat:@"%@: %@", d.allKeys[0], d[d.allKeys[0]]];
                [cell addSubview:t];
                [cell.textFields addObject:t];
                h += 40;
            } else {
                UITextField *t = [[UITextField alloc] initWithFrame:CGRectMake(30, h, kWidth-60, 40)];
                t.text = d[@"value"];
                [cell addSubview:t];
                [cell.textFields addObject:t];
                h += 40;
            }
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = self.contact.profileAttributeKeys[indexPath.row-1];
    if (self.expandedRows[key]) {
        [self.expandedRows removeObjectForKey:key];
    } else {
        self.expandedRows[key] = @YES;
    }
    
    [self.profileTableView beginUpdates];
    [self.profileTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.profileTableView endUpdates];
}


// delete on parse (everything else should be taken care of)
- (void)updatedDeletedTagsInParse {
    NSLog(@"deleting %@", self.deleted);
    
  //  NSMutableArray *parseTags = [self makeParseTags:self.deleted];
 //   [PFObject deleteAllInBackground:parseTags block:^(BOOL succeeded, NSError *error) {
//        if (error) {
//            NSLog(@"Error: %@", [error localizedDescription]);
//        }
//        if (succeeded) {
//            self.deleted = [@[] mutableCopy];
//        }
//    }];
}


// 1. add to parse
// 2. update the objects in the db and save to core data
//- (void)updateAddedTagsInParse {
//    NSLog(@"adding %@", self.added);
//    NSMutableArray *parseTags = [self makeParseTags:self.added];
//    [PFObject saveAllInBackground:parseTags block:^(BOOL succeeded, NSError *error) {
//        if (error) {
//            NSLog(@"Error: %@", error);
//        }
//        if (succeeded) {
//            NSLog(@"save in background succeeeded");
//            NSLog(@"%@", parseTags);
//            [self replaceParseTags:parseTags];
//            self.added = [@[] mutableCopy];
//        }
//    }];
//}

//- (NSMutableArray *)makeParseTags:(NSMutableArray *)ts {
//    NSMutableArray *parseTags = [[NSMutableArray alloc] initWithCapacity:self.added.count];
//    // make all of the array objects a PFObject
//    for (Tag *t in ts) {
//        [parseTags addObject:[t pfObject]];
//    }
//    return parseTags;
//}

//- (void)replaceParseTags:(NSArray *)parseTags {
//    NSLog(@"replaceParseTags");
//    NSMutableDictionary *tagDictionary = [NSMutableDictionary dictionaryWithCapacity:parseTags.count];
//    
//    for (PFObject *parseTag in parseTags) {
//        Tag *tag = [Tag tagFromParse:parseTag];
//        tagDictionary[tag.attributeName] = tag;
//    }
//    
//    NSMutableArray *cts = [self.contact.tags_ mutableCopy];
//    NSInteger i = 0;
//    for (Tag *ct in cts) {
//        if (tagDictionary[ct.attributeName] != nil) {
//            cts[i] = tagDictionary[ct.attributeName];
//        }
//        i++;
//    }
//    
//    NSLog(@"updating in core data");
//    // update in core data
//    FBManager *lim = [FBManager singleton];
//    self.contact.tags_ = [cts copy];
//    [lim.managedObjectContext save:nil];
//}


#pragma mark View Logic
// encapsulating function that writes text in all of the fields and moves the view
// up if no text exists.
- (void)formatLayout {
//    CGFloat moved = 0.0;
    
    // 1. set the image and make it a circle
//    self.contactImage.layer.cornerRadius = self.contactImage.frame.size.height / 2;
//    self.contactImage.clipsToBounds = YES;
//	[self.contactImage setImageWithURL:[NSURL URLWithString:self.contact.pictureUrl] placeholderImage:kContactCellPlaceholderImage];
//    
//    // 2. set the name
//    self.nameLabel.text = self.contact.name;
//    
//    // 3. set the headline
//    self.headlineLabel.text = [self getHeadline];
//    
//    // 4. set the position
//    NSString *positionTitle = [self getPositionTitle];
//    if (positionTitle.length == 0) {
//        moved += [self removeViewOfHeight:self.positionTitleLabel];
//    } else {
//        self.positionTitleLabel.text = positionTitle;
//    }
//    
//    NSString *positionName = [self getPositionName];
//    if (positionName.length == 0) {
//        moved += [self removeViewOfHeight:self.positionNameLabel];
//    } else {
//        [self moveView:self.positionNameLabel upBy:moved andIncreaseHeight:0.0];
//        self.positionNameLabel.text = positionName;
//    }
//    
//    // 5. set the description
//    NSString *description = self.contact.positionSummary;
//    if (description && description.length > 0) {
//        [self moveView:self.positionSummaryText upBy:moved andIncreaseHeight:0.0];
//        self.positionSummaryText.text = description;
//    } else {
//        moved += [self removeViewOfHeight:self.positionSummaryText];
//    }
//    
//    // 6. set up the custom tag view (to be implemented)
//    [self moveView:self.tagsCollectionView upBy:moved andIncreaseHeight:moved];
}

// gives the headline for the Contact
- (NSString *)getHeadline {
    NSString *headline = @"A good friend with no headline";
    if (self.contact.headline && self.contact.headline.length > 0) {
        headline = self.contact.headline;
    }
    return headline;
}

// gets the title for the position
- (NSString *)getPositionTitle {
    NSString *positionTitle = @"";
    if (self.contact.positionTitle && self.contact.positionTitle.length > 0) {
        positionTitle = self.contact.positionTitle;
    }
    return positionTitle;
}

// gets the name for the position
- (NSString *)getPositionName {
    NSString *positionName = @"";
    if (self.contact.positionName && self.contact.positionName.length > 0) {
        positionName = [NSString stringWithFormat:@"At %@", self.contact.positionName];
    }
    return positionName;
}

// removes a subview from the main view and returns how hight
// the next view needs to move "up" to replace that view.
-(CGFloat)removeViewOfHeight:(UIView *)view {
    CGFloat height = view.frame.size.height;
    [view removeFromSuperview];
    return height;
}

// moves the view up and makes it bigger
- (void)moveView:(UIView *)view upBy:(CGFloat)distance andIncreaseHeight:(CGFloat)increase {
    CGRect f = view.frame;
    [view setFrame:CGRectMake(f.origin.x, f.origin.y - distance, f.size.width, f.size.height + increase)];
}

#pragma mark Button Actions
// action for when you press the picture that sends you to linkedin.com
- (IBAction)goToLinkedInProfile:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.contact.linkedInUrl]];
}

#pragma mark CollectionView
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.contactTags.count + 1;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // if it's the last item, you can select it
    if (indexPath.item == self.contactTags.count) {
        return YES;
    } else if (indexPath.item == self.itemToDelete) {
        return YES;
    }
    return NO;
}

// called when the item is selected - will only do anything if the add button
// is selected
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    // if it's the last item, add a new item
    if (indexPath.item == self.contactTags.count) {
        if (self.itemToDelete != -1) {
            NSInteger hold = self.itemToDelete;
            [self clearDeleteViewAtIndex:hold];
        } else {
            [self showAddTagView];
        }
    } else if (indexPath.item == self.itemToDelete) {
        NSInteger hold = self.itemToDelete;
        [self deleteTagAtIndexPath:indexPath];
        [self clearDeleteViewAtIndex:hold];
    }
}

- (void)clearDeleteViewAtIndex:(NSInteger)index {
//    self.itemToDelete = -1;
//    [UIView animateWithDuration:.3 animations:^{
//        [self.tagsCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0], [NSIndexPath indexPathForItem:self.contactTags.count inSection:0]]];
//    }];
}


// style the collectionView cell at the indexPath
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tagCellIdentifier = @"TagCollectionCell";
    [self.tagsCollectionView registerClass:[TagCell class] forCellWithReuseIdentifier:tagCellIdentifier];
    
    TagCell *cell = (TagCell *)[cv dequeueReusableCellWithReuseIdentifier:tagCellIdentifier forIndexPath:indexPath];
    //UILabel *label = (UILabel *)[cell viewWithTag:1];
    UILabel *label = [[UILabel alloc] init];
    NSInteger i = indexPath.item;
    cell.layer.cornerRadius = cell.frame.size.height / 4;
    cell.itemIndex = i;
    cell.delegate = self;
    
    BOOL isReloadingForDelete = (self.itemToDelete != -1);
    // 1. There is no cell being deleted
    if (!isReloadingForDelete) {
        if (i < self.contactTags.count) {
            [cell addLongPress];
            Tag *tag = self.contactTags[i];
            [label setText:tag.attributeName];
            label.textColor = [UIColor blackColor];
        } else {
            label.text = @"+";
            label.font = [UIFont fontWithName:@"Helvetica-Bold" size:50.0];
            float cellHeight = cell.frame.size.height, labelHeight = label.frame.size.height;
            float offset = cellHeight - labelHeight - 3.0;
            label.frame = CGRectMake(0, offset, cell.frame.size.width, labelHeight);
            label.textColor = [UIColor whiteColor];
        }
    } else {
        if (i < self.contactTags.count) {
            [cell turnOnDelete];
        } else {
            label.text = @"Back";
            label.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
            label.textColor = [UIColor whiteColor];
        }
    }
    
    
    [label setTextColor:[UIColor blackColor]];
    //[label setText:@"Android"];
    [label setFrame:CGRectMake(0, 0, 50, 50)];
    [cell.contentView addSubview:label];
    
    NSLog(@"%@", label.text);
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [lab setText:@"DRO"];
    //[cell.contentView addSubview:lab];
    
    return cell;
}


#pragma mark - Tag insert/remove
// adds a Tag object at the indexPath
// adds a Tag object from Core Data


// This is the callback function for the long press on the cell.  Basically,
// it's job is to notify the view controller that someone is trying to delete
// one of the cells.
- (void)didPressCellAtItemIndex:(NSInteger)itemIndex {
    // 1. set the deleted item to the itemIndex
//    if (itemIndex != self.contactTags.count && self.itemToDelete == -1) {
//        self.itemToDelete = itemIndex;
//        [UIView animateWithDuration:.3 animations:^{
//            [self.tagsCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:itemIndex inSection:0], [NSIndexPath indexPathForItem:self.contactTags.count inSection:0]]];
//        }];
//    }
}

- (void)addTagToCollectionView:(Tag *)tag {
    
    for (Tag *check in self.contactTags) {
        // make sure that there are no duplicates
        if ([check.attributeName isEqualToString:tag.attributeName]) {
            return;
        }
    }

    [self.contactTags addObject:tag];
    [self addedTag:tag];
    [self resetContactTags];
  //  [self.tagsCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.contactTags.count - 1 inSection:0]]];
}

- (void)resetContactTags {
    FBManager *lim = [FBManager singleton];
    self.contact.tags_ = [self.contactTags copy];
    [lim.managedObjectContext save:nil];
}

// adds the tag to the added changeList
- (void)addedTag:(Tag *)tag {
    for (Tag *t in self.deleted) {
        NSInteger index = 0;
        if ([t.attributeName isEqualToString:tag.attributeName]) {
            [self.deleted removeObjectAtIndex:index];
            return;
        }
        index++;
    }
    [self.added addObject:tag];
    [self.tagsCollectionView reloadData];
}

// adds the tag to the deleted changeList
- (void)deletedTag:(Tag *)tag {
    for (Tag *t in self.added) {
        NSInteger index = 0;
        if ([t.attributeName isEqualToString:tag.attributeName]) {
            [self.added removeObjectAtIndex:index];
            return;
        }
        index++;
    }
    [self.deleted addObject:tag];
}

// deletes a Tag object at the indexPath
// deletes a Tag object from Core Data
- (void)deleteTagAtIndexPath:(NSIndexPath *)indexPath {
    Tag *tag = [self.contactTags objectAtIndex:indexPath.item];
    [self.contactTags removeObjectAtIndex:indexPath.item];
    [self deletedTag:tag];
    [self resetContactTags];
  //  [self.tagsCollectionView deleteItemsAtIndexPaths:@[indexPath]];
}

// This is is what brings the typeahead view onto the screen and shows the
// the keyboard
- (void)showAddTagView {
    [self.typeAheadViewController showView:YES];
}

// This is the delegate method that is called when on of the items from the
// typeahead is chosen.  It dimisses the keyboard, moves the view offscreen,
// and adds the tag to the collectionView
- (void)cellClickedWithData:(id)data {
    FBManager *lim = [FBManager singleton];
    
    if (self.contact.fbId == nil) {
        [NSException raise:@"Contact has no id" format:@"%@ has no linkedinId", self.contact.name];
//        assert(false);
    }
    
    Tag *t = [Tag tagFromTagOption:(TagOption *)data taggedUser:self.contact.fbId byUser:[lim currenUserId]];

    // 1. make the view go away.
    [self.typeAheadViewController hideView:YES];
    
    // 2. add the Tag
    [self addTagToCollectionView:t];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
