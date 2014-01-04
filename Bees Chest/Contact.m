//
//  Contact.m
//  Bees Chest
//
//  Created by Billy Irwin on 1/3/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import "Contact.h"

@implementation Contact

@dynamic lastName;
@dynamic headline;
@dynamic firstName;
@dynamic linkedInId;
@dynamic industry;
@dynamic pictureUrl;
@dynamic linkedInUrl;

@synthesize profileImage;

+ (Contact*)createContactFromLinkedIn:(NSDictionary*)user {
    LinkedInManager *li = [LinkedInManager singleton];
    Contact *c = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:li.managedObjectContext];
    c.firstName = user[kContactFirstName];
    c.lastName = user[kContactLastName];
    
    // This is where they will appear in the grouping.
    if (c.lastName && c.lastName.length > 0) {
        c.groupByLastName = [[c.lastName substringToIndex:1] uppercaseString];
    } else if (c.firstName && c.firstName.length > 0) {
        c.groupByLastName = [[c.firstName substringToIndex:1] uppercaseString];
    } else {
        // if they don't have a name, make them appear last.
        c.groupByLastName = @"Z";
    }
    
    c.linkedInId = user[kContactLinkedInId];
    c.industry = user[kContactIndustry];
    c.headline = user[kContactHeadline];
    c.pictureUrl = user[kContactPicUrl];
    return c;
}

- (void)loadImage
{
    if (!self.profileImage) {
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSLog(@"%@", self.pictureUrl);
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.pictureUrl]];
            if ( data == nil )
                return;
            self.profileImage = [UIImage imageWithData:data];
        });
    }
}

@end
