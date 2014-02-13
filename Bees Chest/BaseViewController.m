//
//  BaseViewController.m
//  Tag
//
//  Created by Billy Irwin on 12/3/13.
//  Copyright (c) 2013 Arbrr. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (id)initWithOnFrame:(CGRect)onFrame andOffFrame:(CGRect)offFrame
{
    self = [super init];
    if (self) {
        self.onFrame = onFrame;
        self.offFrame = offFrame;
        self.isOnScreen = false;
        self.keyboardVisible = false;
    
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserver:self selector:@selector(noticeShowKeyboard:) name:UIKeyboardDidShowNotification object:nil];
		[center addObserver:self selector:@selector(noticeHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTouched:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backgroundTouched:(id)sender
{
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //NSLog(@"should recognize touch %i %i", self.keyboardVisible, self.isOnScreen);
    //NSLog(@"%@", gestureRecognizer);
    return self.keyboardVisible;
}

//- (BOOL)removeAllResponder:(UIView*)v
//{
//    if ([v isFirstResponder]) {
//        [v resignFirstResponder];
//        return YES;
//    }
//    for (UIView *v2 in v.subviews) {
//        if ([self removeAllResponder:v2]) {
//            return YES;
//        }
//    }
//    return NO;
//}

- (void)flashMessage:(NSString *)message isError:(BOOL)err {
}

- (void)moveOffScreen
{
    self.view.frame = self.onFrame;
    self.isOnScreen = false;
    //self.view.alpha = 0;
}

- (void)moveOnScreen
{
    self.view.frame = self.onFrame;
    self.isOnScreen = YES;
    self.view.alpha = 1;
    [self.view.superview bringSubviewToFront:self.view];
}

//- (void)clearTF:(UIView*)v
//{
//    if ([v isKindOfClass:[UITextField class]]) {
//        [(UITextField*)v setText:@""];
//    }
//    
//    for (UIView *v2 in v.subviews) {
//        [self clearTF:v2];
//    }
//}

-(void) noticeShowKeyboard:(NSNotification *)inNotification {
	self.keyboardVisible = true;
}

-(void) noticeHideKeyboard:(NSNotification *)inNotification {
	self.keyboardVisible = false;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"%i", textField.tag);
    if (textField.tag == 5) {
        NSLog(@"lets go");
        int length = [self getLength:textField.text];
        
        if(length == 10) {
            if(range.length == 0)
                return NO;
        }
        
        if(length == 3) {
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"(%@) ",num];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
        }
        else if(length == 6) {
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
        }
    }
    return YES;
}

- (NSString*)formatPhoneNumber:(NSString*)mobileNumber
{
    // Removing format characters
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
// Cutting off the phone number at 10 digits
    if (mobileNumber.length > 15) {
        mobileNumber = [mobileNumber substringToIndex:15];
    }
    
    if ([mobileNumber characterAtIndex:0] == '#') {
        // No formatting
        return mobileNumber;
    }
    
    // 1-first behavior still needed
    if ([mobileNumber characterAtIndex:0] == '1') {
        if (mobileNumber.length == 2) {
            mobileNumber = [NSString stringWithFormat:@"1 (%@  )", [mobileNumber substringFromIndex:1]];
        }
        else if (mobileNumber.length == 3) {
            // Looks the same as the first case, but has one less space in parentheses
            mobileNumber = [NSString stringWithFormat:@"1 (%@ )", [mobileNumber substringFromIndex:1]];
        }
        else if (mobileNumber.length == 4) {
            // Looks the same as the second case, but has one less space in parentheses
            mobileNumber = [NSString stringWithFormat:@"1 (%@)", [mobileNumber substringFromIndex:1]];
        }
        else if (mobileNumber.length >= 5 && mobileNumber.length <= 7) {
            NSString *first = [mobileNumber substringWithRange:NSMakeRange(1, 3)];
            NSString *second = [mobileNumber substringFromIndex:4];
            mobileNumber = [NSString stringWithFormat:@"1 (%@) %@", first, second];
        }
        else if (mobileNumber.length >= 8 && mobileNumber.length <= 11) {
            NSString *first = [mobileNumber substringWithRange:NSMakeRange(1, 3)];
            NSString *second = [mobileNumber substringWithRange:NSMakeRange(4,3)];
            NSString *third = [mobileNumber substringFromIndex:7];
            mobileNumber = [NSString stringWithFormat:@"1 (%@) %@-%@", first,second,third];
        }
        return mobileNumber;
    }
    
    // Formatting the number without 1 as the first character
    if (mobileNumber.length >= 4 && mobileNumber.length <= 7) {
        mobileNumber = [NSString stringWithFormat:@"%@-%@", [mobileNumber substringToIndex:3], [mobileNumber substringFromIndex:3]];
    }
    else if (mobileNumber.length >= 8 && mobileNumber.length <= 10) {
        NSString *first = [mobileNumber substringToIndex:3];
        NSString *second = [mobileNumber substringWithRange:NSMakeRange(3, 3)];
        NSString *third = [mobileNumber substringFromIndex:6];
        mobileNumber = [NSString stringWithFormat:@"(%@) %@-%@", first, second, third];
    }
    
    return mobileNumber;
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = [mobileNumber length];
    if(length > 10) {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
    }
    return mobileNumber;
}


-(int)getLength:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = [mobileNumber length];
    return length;
}




@end
