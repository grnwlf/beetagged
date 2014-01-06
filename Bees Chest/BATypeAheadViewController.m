//
//  BATypeAheadViewController.m
//  Bees Chest
//
//  Created by Billy Irwin on 1/1/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import "BATypeAheadViewController.h"

@interface BATypeAheadViewController ()
@property (nonatomic, assign) CGRect customFrame;
@end

@implementation BATypeAheadViewController

- (id)initWithFrame:(CGRect)frame andData:(NSArray *)data
{
    self = [super init];
    if (self) {
        self.customFrame = frame;
        self.data = data;
        self.searchData = [[NSMutableArray alloc] init];
        self.view.tableView.delegate = self;
        self.view.tableView.dataSource = self;
        self.view.inputTextField.delegate = self;
    }
    return self;
}

- (void)loadView {
    self.view = [[BATypeAheadView alloc] initWithFrame:self.customFrame];
}

- (void)hideView:(BOOL)animated {
    CGRect curFrame = self.view.frame;
    CGRect offscreen = CGRectMake(curFrame.origin.x, curFrame.origin.y - kHeight, curFrame.size.width, curFrame.size.height);
    
    if (animated) {
        [UIView animateWithDuration:.4 animations:^{
            self.view.frame = offscreen;
        } completion:^(BOOL finished) {
            self.view.inputTextField.text = @"";
            self.searchData = [@[] mutableCopy];
            [self.view hideTableView];
            [self.view.tableView reloadData];
        }];
    } else {
        self.view.frame = offscreen;
    }
}


- (void)showView:(BOOL)animated {
    CGRect curFrame = self.view.frame;
    CGRect onScreen = CGRectMake(curFrame.origin.x, curFrame.origin.y + kHeight, curFrame.size.width, curFrame.size.height);
    
    if (animated) {
        [UIView animateWithDuration:.4 animations:^{
            self.view.frame = onScreen;
        } completion:^(BOOL finished) {
            NSLog(@"Moved view");
        }];
    } else {
        self.view.frame = onScreen;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return self.searchData.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBATypeAheadCellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TypeAheadCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Tag *tag = self.searchData[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Thin" size:14.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = tag.attributeName;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate cellClickedWithData:self.searchData[indexPath.row]];
}

#pragma mark UITextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSLog(@"%@", string);
    NSString *query = [NSString stringWithFormat:@"%@%@", self.view.inputTextField.text, string];
    if ([string isEqualToString:@""]) {
        NSLog(@"backspace");
        query = [query substringToIndex:query.length-1];
    }
    query = [[query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    NSLog(@"%@", query);
    
    if (query.length == 0) {
        self.isTyping = false;
        [self hideAndClearTableView];
    } else {
        self.isTyping = true;

        NSPredicate *queryName = [NSPredicate predicateWithBlock:^BOOL(Tag *evaluatedObject, NSDictionary *bindings) {
            return [[evaluatedObject.attributeName lowercaseString] rangeOfString:query].location != NSNotFound;
        }];
        self.searchData = (NSMutableArray*)[self.data filteredArrayUsingPredicate:queryName];
        NSLog(@"search data: %@", self.searchData);
        [self showTableView];
    }
    [self.view.tableView reloadData];
    return true;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.searchData = [@[] mutableCopy];
    [self.view.tableView reloadData];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view.inputTextField resignFirstResponder];
    return NO;
}

- (void)hideAndClearTableView
{
    [self.view hideTableView];
    self.searchData = [@[] mutableCopy];
    [self.view.tableView reloadData];
}

- (void)showTableView
{
    [self.view showTableViewWithHeight:(self.searchData.count*kBATypeAheadCellHeight)];
    [self.view.tableView reloadData];
}

@end
