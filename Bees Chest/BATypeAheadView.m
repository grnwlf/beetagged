//
//  BATypeAheadView.m
//  Bees Chest
//
//  Created by Billy Irwin on 1/1/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import "BATypeAheadView.h"

#define kTableViewHidden CGRectMake(0, 50, self.frame.size.width, 0)
#define kTableViewVisible(h) CGRectMake(0, 50, self.frame.size.width, h)

@implementation BATypeAheadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        self.tableView = [[UITableView alloc] initWithFrame:kTableViewHidden style:UITableViewStylePlain];
        self.inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width-20, 45)];
        self.inputTextField.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.tableView];
        [self addSubview:self.inputTextField];
    }
    return self;
}

- (void)hideTableView
{
    self.tableView.frame = kTableViewHidden;
}

- (void)showTableViewWithHeight:(CGFloat)height
{
    float h = MIN(400, height);
    self.tableView.frame = kTableViewVisible(h);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
