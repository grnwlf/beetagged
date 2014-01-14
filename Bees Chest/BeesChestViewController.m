//
//  BeesChestViewController.m
//  Bees Chest
//
//  Created by Billy Irwin on 1/1/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import "BeesChestViewController.h"

#define kP1ScreenOn CGRectMake(0, 40, kWidth, kHeight/2 - 20)
#define kP1ScreenOff CGRectMake(-kWidth, 40, kWidth, kHeight/2 - 20)

#define kP2ScreenOn CGRectMake(0, 40+kHeight/2 - 20, kWidth, kHeight/2 - 20)
#define kP2ScreenOff CGRectMake(kWidth, 40+kHeight/2 - 20, kWidth, kHeight/2 - 20)

@interface BeesChestViewController ()

@end

@implementation BeesChestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.p1View.frame = kP1ScreenOff;
    self.p2View.frame = kP2ScreenOff;
    self.stopBtn.alpha = 0;
    [self typeahead];
    self.players = [[NSMutableArray alloc] init];
    srand(time(NULL));
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)stopGame:(id)sender {
    [self endTurnandDone:YES];
}

- (IBAction)choosePlayer1:(id)sender {
    NSLog(@"touched");
    [self endTurnandDone:NO];
}

- (IBAction)choosePlayer2:(id)sender {
    [self endTurnandDone:NO];
}

- (IBAction)playGame:(id)sender {
    [self.typeAheadViewController showView:YES];
}

- (IBAction)chooseP1:(id)sender {
    NSLog(@"p1");
    [self endTurnandDone:NO];
}

- (IBAction)chooseP2:(id)sender {
    NSLog(@"p2");
    [self endTurnandDone:NO];
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

- (void)startTurn
{
    [self chooseTwoContacts];
    [self.p1ImageView setImageWithURL:[NSURL URLWithString:self.p1.pictureUrl] placeholderImage:kContactCellPlaceholderImage];
    [self.p2ImageView setImageWithURL:[NSURL URLWithString:self.p2.pictureUrl] placeholderImage:kContactCellPlaceholderImage];
    self.p1NameLabel.text = self.p1.name;
    self.p2NameLabel.text = self.p2.name;
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.p1View.frame = kP1ScreenOn;
        self.p2View.frame = kP2ScreenOn;
        self.stopBtn.alpha = 1;
        self.playGameBtn.alpha = 0;
    } completion:nil];
}

- (void)endTurnandDone:(BOOL)done
{
    [UIView animateWithDuration:0.3 animations:^{
        self.p1View.frame = kP1ScreenOff;
        self.p2View.frame = kP2ScreenOff;
    } completion:^(BOOL finished) {
        if (!done) [self startTurn];
        else {
            self.stopBtn.alpha = 0;
            self.playGameBtn.alpha = 1;
            self.gameLabel.text = @"";
        }
    }];
}

- (void)chooseTwoContacts
{
    FBManager *li = [FBManager singleton];

    int i = rand() % self.players.count;
    int j = i;
    while (i == j) {
        j = rand() % self.players.count;
    }
    
    self.p1 = self.players[i];
    self.p2 = self.players[j];
}

- (void)cellClickedWithData:(id)data
{
    [self.typeAheadViewController hideView:YES];
    [self.players removeAllObjects];
    TagOption *t = (TagOption*)data;
    FBManager *li = [FBManager singleton];
    for (Contact *c in li.fetchedResultsController.fetchedObjects) {
        for (Tag *tag in c.tags_) {
            NSLog(@"%@ %@", tag.attributeName, t.attributeName);
            if ([tag.attributeName isEqualToString:t.attributeName]) {
                [self.players addObject:c];
                break;
            }
        }
    }
    
    NSLog(@"here are the players");
    for (Contact *c in self.players) {
        NSLog(@"%@", c.name);
        for (Tag *t in c.tags_) {
            NSLog(@"%@", t.attributeName);
        }
        NSLog(@"");
    }
    
    self.gameLabel.text = t.attributeName;
    
    if (self.players.count > 2) {
        [self startTurn];
    } else {
        [self endTurnandDone:YES];
    }
}
@end
