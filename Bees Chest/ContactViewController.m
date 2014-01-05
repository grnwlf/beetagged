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
    }
    return self;
}

#pragma mark View Loading
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tagsCollectionView.delegate = self;
    self.tagsCollectionView.dataSource = self;
    self.contactTags = [@[@"tag1", @"tag2", @"tag3", @"tag4", @"tag5", @"tag6", @"tag7", @"tag8", @"tag9", @"tag9"] mutableCopy];
    [self formatLayout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

#pragma mark View Logic
// encapsulating function that writes text in all of the fields and moves the view
// up if no text exists.
- (void)formatLayout {
    CGFloat moved = 0.0;
    
    // 1. set the image and make it a circle
    self.contactImage.layer.cornerRadius = self.contactImage.frame.size.height / 2;
    self.contactImage.clipsToBounds = YES;
	[self.contactImage setImageWithURL:[NSURL URLWithString:self.contact.pictureUrl] placeholderImage:kContactCellPlaceholderImage];
    
    // 2. set the name
    self.nameLabel.text = self.contact.formattedName;
    
    // 3. set the headline
    self.headlineLabel.text = [self getHeadline];
    
    // 4. set the position
    NSString *positionTitle = [self getPositionTitle];
    if (positionTitle.length == 0) {
        moved += [self removeViewOfHeight:self.positionTitleLabel];
    } else {
        self.positionTitleLabel.text = positionTitle;
    }
    
    NSString *positionName = [self getPositionName];
    if (positionName.length == 0) {
        moved += [self removeViewOfHeight:self.positionNameLabel];
    } else {
        [self moveView:self.positionNameLabel upBy:moved andIncreaseHeight:0.0];
        self.positionNameLabel.text = positionName;
    }
    
    // 5. set the description
    NSString *description = self.contact.positionSummary;
    if (description && description.length > 0) {
        [self moveView:self.positionSummaryText upBy:moved andIncreaseHeight:0.0];
        self.positionSummaryText.text = description;
    } else {
        moved += [self removeViewOfHeight:self.positionSummaryText];
    }
    
    // 6. set up the custom tag view (to be implemented)
    [self moveView:self.tagsCollectionView upBy:moved andIncreaseHeight:moved];
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
    
    return 10;
    
    int maxInCol = self.contactTags.count / kTagsNumberOfSections;
    int rowsWithMax = self.contactTags.count % kTagsNumberOfSections;
    
    if (rowsWithMax == 0) {
        return maxInCol;
    } else {
        if (rowsWithMax > section) {
            return maxInCol;
        } else {
            return maxInCol - 1;
        }
    }
}

// converts an indexPath into an index (like index of an array)
-(NSInteger)indexFromIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row, section = indexPath.section;
    return row + section * kTagsNumberOfSections;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tagCellIdentifier = @"TagCollectionCell";
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:tagCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    NSInteger i = [self indexFromIndexPath:indexPath];
    label.text = self.contactTags[i];
    label.textColor = [UIColor blueColor];
    return cell;
}

#pragma mark Moving Delegate Functions
// make the chance in the Tag Array
- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    NSString *tag = [self.contactTags objectAtIndex:fromIndexPath.item];
    [self.contactTags removeObjectAtIndex:fromIndexPath.item];
    [self.contactTags insertObject:tag atIndex:toIndexPath.item];
}

// don't let you move the last item
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.contactTags.count - 1) {
        return NO;
    }
    return YES;
}

// can't make anything last in the indexPath
- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
    if (toIndexPath.item == self.contactTags.count - 1) {
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
