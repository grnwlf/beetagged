//
//  BATypeAheadViewController.m
//  Bees Chest
//
//  Created by Billy Irwin on 1/1/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import "BATypeAheadViewController.h"

@interface BATypeAheadViewController ()

@end

#define kCellHeight 50

@implementation BATypeAheadViewController

- (id)initWithFrame:(CGRect)frame andData:(NSArray *)data
{
    self = [super init];
    if (self) {
        self.view = [[BATypeAheadView alloc] initWithFrame:frame];
        self.data = data;
        self.searchData = [[NSMutableArray alloc] init];
        
        self.view.tableView.delegate = self;
        self.view.tableView.dataSource = self;
        self.view.inputTextField.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
    return kCellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TypeAheadCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = self.searchData[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate cellClickedWithData:self.searchData[indexPath.row]];
}

#pragma mark UITextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"%@", string);
    NSString *query = [NSString stringWithFormat:@"%@%@", self.view.inputTextField.text, string];
    if ([string isEqualToString:@""]) {
        NSLog(@"backspace");
        query = [query substringToIndex:query.length-1];
    }
    query = [query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"%@", query);
    
    if (query.length == 0) {
        self.isTyping = false;
        [self hideAndClearTableView];
    } else {
        self.isTyping = true;
        NSPredicate *queryNames = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", query];
        self.searchData = (NSMutableArray*)[self.data filteredArrayUsingPredicate:queryNames];
        NSLog(@"search data: %@", self.searchData);
        [self showTableView];
    }
    return true;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.searchData = @[];
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
    self.searchData = @[];
    [self.view.tableView reloadData];
}

- (void)showTableView
{
    [self.view showTableViewWithHeight:(self.searchData.count*kCellHeight)];
    [self.view.tableView reloadData];
}

@end
