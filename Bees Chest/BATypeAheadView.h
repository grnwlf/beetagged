//
//  BATypeAheadView.h
//  Bees Chest
//
//  Created by Billy Irwin on 1/1/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BATypeAheadView : UIView

@property (strong, nonatomic) UITextField *inputTextField;
@property (strong, nonatomic) UITableView *tableView;

- (void)hideTableView;
- (void)showTableViewWithHeight:(CGFloat)height;

@end
