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
@dynamic groupByLastName;

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
    [c addToCache];
    return c;
}

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


//apiStandardProfileRequest =             {
//    headers =                 {
//        "_total" = 1;
//        values =                     (
//                                      {
//                                          name = "x-li-auth-token";
//                                          value = "name:FFci";
//                                      }
//                                      );
//    };
//    url = "http://api.linkedin.com/v1/people/btkEInCrdT";
//};
//firstName = Pavitra;
//headline = "Student at The University of Michigan";
//id = btkEInCrdT;
//industry = "Political Organization";
//lastName = Abraham;
//location =             {
//    country =                 {
//        code = us;
//    };
//    name = "Greater Detroit Area";
//};
//pictureUrl = "http://m.c.lnkd.licdn.com/mpr/mprx/0_OPQTE-kC1IiOYrjkOB9OEl8G1Hc7yvukpctOElFO2DiY_AUXtvnSXAPrjQBl0tSe0Kkx59MZ5YzX";
//siteStandardProfileRequest =             {
//    url = "http://www.linkedin.com/profile/view?id=218395364&authType=name&authToken=FFci&trk=api*a3118083*s3192683*";
//};
//},

@end
