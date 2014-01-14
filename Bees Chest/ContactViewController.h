//
//  ContactViewController.h
//  Bees Chest
//
//  Created by Billy Irwin on 1/1/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "TagCell.h"
#import "BATypeAheadViewController.h"
#import "FBManager.h"
#import "ContactTransition.h"
#import "TagCell.h"

@interface ContactViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TagCellDelegate>

@property (nonatomic, strong) Contact *contact;
@property (nonatomic, strong) BATypeAheadViewController *typeAheadViewController;
@property (nonatomic, strong) BATypeAheadView *typeAheadView;
@property (strong, nonatomic) IBOutlet UIImageView *contactImage;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *headlineLabel;
@property (strong, nonatomic) IBOutlet UILabel *positionTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *positionNameLabel;
@property (strong, nonatomic) IBOutlet UITextView *positionSummaryText;
@property (strong, nonatomic) IBOutlet UICollectionView *tagsCollectionView;
@property (strong, nonatomic) NSMutableArray *contactTags;



@end
