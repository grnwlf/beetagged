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
@interface ContactsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *ContactTableView;

@end
