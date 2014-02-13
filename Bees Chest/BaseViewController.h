//
//  BaseViewController.h
//  Tag
//
//  Created by Billy Irwin on 12/3/13.
//  Copyright (c) 2013 Arbrr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController <UIGestureRecognizerDelegate, UITextFieldDelegate>


@property (weak, nonatomic) id parent;
@property (nonatomic) CGRect onFrame;
@property (nonatomic) CGRect offFrame;
@property (nonatomic) BOOL isOnScreen;
@property (nonatomic) BOOL keyboardVisible;


- (IBAction)backgroundTouched:(id)sender;
- (id)initWithOnFrame:(CGRect)onFrame andOffFrame:(CGRect)offFrame;
- (void)moveOnScreen;
- (void)moveOffScreen;
- (void)setNavBarImage:(UIImage*)image;
- (void)startActivity;
- (void)endActivity;
- (NSString*)formatPhoneNumber:(NSString*)mobileNumber;
- (void)flashMessage:(NSString *)message isError:(BOOL)err;

@end
