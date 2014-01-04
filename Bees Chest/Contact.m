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

+ (Contact*)createContactFromLinkedIn:(NSDictionary*)user
{
    LinkedInManager *li = [LinkedInManager singleton];
    Contact *c = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:li.managedObjectContext];
    c.firstName = user[kContactFirstName];
    c.lastName = user[kContactLastName];
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
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.pictureUrl]];
            NSLog(@"got data back");
            if ( data == nil )
                return;
            NSLog(@"setting picture");
            self.profileImage = [UIImage imageWithData:data];
        });
    }
}

@end
