//
//  ViewController.h
//  Bees Chest
//
//  Created by Billy Irwin on 12/29/13.
//  Copyright (c) 2013 Arbrr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BATypeAheadViewController.h"

@interface ViewController : UIViewController <BATypeAheadDelegate>

@property (strong, nonatomic) BATypeAheadViewController *b;

- (IBAction)login:(id)sender;

@end
