//
//  Contact.m
//  Bees Chest
//
//  Created by Billy Irwin on 1/3/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import "Contact.h"

@implementation Contact

@dynamic linkedInId;
@dynamic firstName;
@dynamic lastName;
@dynamic formattedName;
@dynamic headline;
@dynamic locationName;
@dynamic positionIndustry;
@dynamic positionName;
@dynamic positionSize;
@dynamic positionIsCurrent;
@dynamic positionSummary;
@dynamic positionTitle;
@dynamic industry;
@dynamic pictureUrl;
@dynamic linkedInUrl;
@dynamic groupByLastName;


+ (Contact*)createContactFromLinkedIn:(NSDictionary*)user {
    LinkedInManager *li = [LinkedInManager singleton];
    Contact *c = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:li.managedObjectContext];
    c.linkedInId = user[kContactLinkedInId];
    c.firstName = user[kContactFirstName];
    c.lastName = user[kContactLastName];
    c.formattedName = user[kContactFormattedName];
    c.headline = user[kContactHeadline];
    [c getLocationFromJSON:user];
    [c getPositionFromJSON:user];
    c.industry = user[kContactIndustry];
    
    c.pictureUrl = user[kContactPicUrl];
    c.linkedInUrl = user[kContactLinkedInGetUrl][kContactLinkedInUrl];

    // This is where they will appear in the grouping.
    if (c.lastName && c.lastName.length > 0) {
        c.groupByLastName = [[c.lastName substringToIndex:1] uppercaseString];
    } else if (c.firstName && c.firstName.length > 0) {
        c.groupByLastName = [[c.firstName substringToIndex:1] uppercaseString];
    } else {
        c.groupByLastName = @"Z";
    }
    
    
    [c addToCache];
    return c;
}

// adds the location json to the model file.
-(void)getLocationFromJSON:(NSDictionary *)json {
    NSString *location = @"";
    NSDictionary * locationJSON = json[kContactLocation];
    if (locationJSON) {
        NSString *temp = locationJSON[kContactLocationName];
        if (temp) {
            location = temp;
        }
    }
    self.locationName = location;
}

// adds the positions JSON to model.
-(void)getPositionFromJSON:(NSDictionary *)json {
    
    if (json[kContactPosition] && json[kContactPosition][kContactPositionValues] && json[kContactPosition][kContactPositionValues][0]) {
        NSDictionary *position = json[kContactPosition][kContactPositionValues][0];
        
        self.positionIsCurrent = [position[kContactPositionIsCurrent] boolValue];
        self.positionSummary = position[kContactPositionSummary];
        self.positionTitle = position[kContactPositionTitle];
        
        NSDictionary *company = position[kContactPositionCompany];
        if (company) {
            self.positionIndustry = company[kContactPositionIndustry];
            self.positionName = company[kContactPositionName];
            self.positionSize = company[kContactPositionSize];
        } else {
            self.positionIndustry = @"";
            self.positionName = @"";
            self.positionSize = @"";
        }
    }
}


// add the picture to the image cache asynchronously
- (void)addToCache {
    SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
    NSURL *url = [NSURL URLWithString:self.pictureUrl];
    __weak NSURL *weakUrl = url;
    [downloader downloadImageWithURL:url options:SDWebImageDownloaderContinueInBackground progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        NSString *key = [self cacheKeyForURL:weakUrl];
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache storeImage:image forKey:key toDisk:YES];
    }];
}


- (NSString *)cacheKeyForURL:(NSURL *)url {
    return [url absoluteString];
}


@end
