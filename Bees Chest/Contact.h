//
//  Contact.h
//  Bees Chest
//
//  Created by Billy Irwin on 1/3/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * headline;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * linkedInId;
@property (nonatomic, retain) NSString * industry;
@property (nonatomic, retain) NSString * pictureUrl;
@property (nonatomic, retain) NSString * linkedInUrl;

@property (strong, nonatomic) UIImage * profileImage;

+ (Contact*)createContactFromLinkedIn:(NSDictionary*)user;
- (void)loadImage;

@end
