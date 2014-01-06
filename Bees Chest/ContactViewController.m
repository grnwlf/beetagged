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
    self.tagsCollectionView.backgroundColor = [UIColor clearColor];
    
    [self formatLayout];
    self.contactTags = [self.contact.tags_ mutableCopy];
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
    return self.contactTags.count + 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    // if it's the last item, add a new item
    if (indexPath.item == self.contactTags.count) {
        [self addTagToCollectionView:nil]; // starfish -- fix this shit.
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tagCellIdentifier = @"TagCollectionCell";
    TagCell *cell = (TagCell *)[cv dequeueReusableCellWithReuseIdentifier:tagCellIdentifier forIndexPath:indexPath];
    cell.layer.cornerRadius = cell.frame.size.height / 4;
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    NSInteger i = indexPath.item;
    if (i < self.contactTags.count) {
        Tag *tag = self.contactTags[i];
        label.text = tag.attributeName;
        label.textColor = [UIColor yellowColor];
    } else {
        label.text = @"+";
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:50.0];
        float cellHeight = cell.frame.size.height, labelHeight = label.frame.size.height;
        float offset = cellHeight - labelHeight - 3.0;
        label.frame = CGRectMake(0, offset, cell.frame.size.width, labelHeight);
        label.textColor = [UIColor whiteColor];
    }
    return cell;
}

#pragma mark - Tag insert/remove
- (void)addTagToCollectionView:(Tag *)tag {
    
    [self showAddTagView];
    
//    Tag *t = [[Tag alloc] init];
//    t.attributeName = @"Cock";
//    
//    [self.contactTags addObject:t];
//    [self.tagsCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.contactTags.count - 1 inSection:0]]];
}

- (void)deleteTagAtIndexPath:(NSIndexPath *)indexPath {
    [self.contactTags removeObjectAtIndex:indexPath.item];
    [self.tagsCollectionView deleteItemsAtIndexPaths:@[indexPath]];
}

- (void)showAddTagView {
    
    float paddingX = 60.0, paddingY = 80.0;
    float width = self.view.frame.size.width - (paddingX * 2);
    float height = self.view.frame.size.height - (paddingY * 2);
    BATypeAheadViewController *typeAhead = [[BATypeAheadViewController alloc] initWithFrame:CGRectMake(paddingX, paddingY, width, height) andData:[[LinkedInManager singleton] tagOptionsArray]];
    typeAhead.delegate = self;
    
    [self presentViewController:typeAhead animated:YES completion:nil];
}

- (void)cellClickedWithData:(id)data {
    Tag *t = (Tag *)data;
    NSLog(@"Clicked %@", t.attributeName);
}


//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
//    
//    // Upon tapping an item, delete it. If it's the last item (the add cell), add a new one
//    NSArray *colorNames = self.sectionedColorNames[indexPath.section];
//    
//    if (indexPath.item == colorNames.count)
//    {
//        [self addNewItemInSection:indexPath.section];
//    }
//    else
//    {
//        [self deleteItemAtIndexPath:indexPath];
//    }
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






@end
