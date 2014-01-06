//
//  Contact.h
//  Bees Chest
//
//  Created by Billy Irwin on 1/3/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/SDWebImageManager.h>
#import "LinkedInManager.h"
#import "Tag.h"
#import "TagOption.h"
#import "LinkedInManager.h"
#import <Parse/Parse.h>

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * linkedInId;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * formattedName;
@property (nonatomic, retain) NSString * headline;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) NSString * industry;
@property (nonatomic, retain) NSString * positionIndustry;
@property (nonatomic, retain) NSString * positionName;
@property (nonatomic, retain) NSString * positionSize;
@property (nonatomic, retain) NSData *tagData;
@property (nonatomic) BOOL positionIsCurrent;
@property (nonatomic) BOOL hasGeneratedTags;
@property (nonatomic, retain) NSString * positionSummary;
@property (nonatomic, retain) NSString * positionTitle;
@property (nonatomic, retain) NSString * pictureUrl;
@property (nonatomic, retain) NSString * linkedInUrl;
@property (nonatomic, retain) NSString * groupByLastName;
@property (nonatomic, strong) NSArray * tags_;



+ (Contact*)contactFromLinkedIn:(NSDictionary*)user;
- (void)generateTags:(BOOL)pushToParse;
+ (void)setParseUser:(NSDictionary *)json andSave:(BOOL)save;

@end
