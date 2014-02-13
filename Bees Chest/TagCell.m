//
//  TagCell.m
//  Bees Chest
//
//  Created by Chris O'Neil on 1/5/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import "TagCell.h"

@implementation TagCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.label];
    }
    return self;
}

#define kTagCellLabelOrigin CGRectMake(0.0, -1.0, 82.0, 40.0)

-(void)prepareForReuse {
    [super prepareForReuse];
    self.itemIndex = -1;
    
    UILabel *label = (UILabel *)[self viewWithTag:1];
    label.font = [UIFont fontWithName:@"Helvetica-Light" size:15.0];
    label.frame = kTagCellLabelOrigin;
    
    self.backgroundColor = [UIColor grayColor];
    
    for (UIGestureRecognizer *gr in self.gestureRecognizers) {
        [self removeGestureRecognizer:gr];
    }
}

- (void)addLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    longPress.delegate = self;
    [longPress addTarget:self action:@selector(heldCell:)];
    longPress.minimumPressDuration = .5;
    [self addGestureRecognizer:longPress];
}

// fired off if you long press the cell
-(void)heldCell:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self.delegate didPressCellAtItemIndex:self.itemIndex];
    }
}

- (void)turnOnDelete {
    self.backgroundColor = [UIColor redColor];
    UILabel *label = (UILabel *)[self viewWithTag:1];
    label.textColor = [UIColor whiteColor];
    label.text = @"Delete";
}

@end
