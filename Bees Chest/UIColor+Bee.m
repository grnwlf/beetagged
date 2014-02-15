//
//  UIColor+Bee.m
//  Bees Chest
//
//  Created by Chris O'Neil on 2/14/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import "UIColor+Bee.h"

@implementation UIColor (Bee)

// Thanks to http://stackoverflow.com/questions/3805177/how-to-convert-hex-rgb-color-codes-to-uicolor
+ (UIColor *) colorFromHexCode:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if ([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

// the darker yellow of the bee icon.
+(UIColor *)goldBeeColor {
    return [UIColor colorFromHexCode:@"FD9E31"];
}

// the lighter color of the bee icon
+(UIColor *)yellowBeeColor {
    return [UIColor colorFromHexCode:@"FFEC16"];
}

// a light gray color
+ (UIColor *)cloudsColor {
    return [UIColor colorFromHexCode:@"ECF0F1"];
}


@end
