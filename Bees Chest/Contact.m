//
//  Contact.m
//  Bees Chest
//
//  Created by Billy Irwin on 1/3/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import "Contact.h"

@implementation Contact

@dynamic fbId;
@dynamic first_name;
@dynamic last_name;
@dynamic name;
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
@dynamic hasGeneratedTags;
@dynamic tagData;
@synthesize tags_;


-(id)init {
    self = [super init];
    if (self) {
        self.hasGeneratedTags = NO;
    }
    return self;
}

#pragma mark JSON
+ (Contact*)contactFromFB:(NSDictionary*)user {
    FBManager *li = [FBManager singleton];
    Contact *c = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:li.managedObjectContext];
    c.fbId = user[kContactFBId];
    c.first_name = user[kContactFirstName];
    c.last_name = user[kContactLastName];
    c.name = user[kContactFormattedName];
    //c.headline = user[kContactHeadline];
//    [c getLocationFromJSON:user];
//    [c getPositionFromJSON:user];
   // c.industry = user[kContactIndustry];
    
    c.pictureUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal", c.fbId];
    //c.linkedInUrl = user[kContactLinkedInGetUrl][kContactLinkedInUrl];

    // This is where they will appear in the grouping.
    if (c.last_name && c.last_name.length > 0) {
        c.groupByLastName = [[c.last_name substringToIndex:1] uppercaseString];
    } else if (c.first_name && c.first_name.length > 0) {
        c.groupByLastName = [[c.first_name substringToIndex:1] uppercaseString];
    } else {
        c.groupByLastName = @"Z";
    }
    
    [c addToCache];
    return c;
}

-(NSArray *)getValidStrings {
    NSMutableArray *v = [@[] mutableCopy];
    
    if (self.headline && self.headline.length > 0) {
        [v addObject:self.headline];
    }
    
    if (self.positionIndustry && self.positionIndustry.length > 0) {
        [v addObject:self.positionIndustry];
    }
    
    if (self.positionSummary && self.positionSummary.length > 0) {
        [v addObject:self.positionSummary];
    }
    
    if (self.positionTitle && self.positionTitle.length > 0) {
        [v addObject:self.positionTitle];
    }
    
    if (self.industry && self.industry.length > 0) {
        [v addObject:self.industry];
    }
    return v;
}

// adds the location json to the model file.
-(void)getLocationFromJSON:(NSDictionary *)json {
//    NSString *location = @"";
//    NSDictionary * locationJSON = json[kContactLocation];
//    if (locationJSON) {
//        NSString *temp = locationJSON[kContactLocationName];
//        if (temp) {
//            location = temp;
//        }
//    }
//    self.locationName = location;
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

#pragma mark Image Cache
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

#pragma mark Parse
// This function sets the parse user when signed up.  Make sure to set the parse
// user differently if you are logging in rather than signing up for the first
// time.
+ (void)setParseUser:(NSDictionary *)json andSave:(BOOL)save {
    PFUser *user = [PFUser user];
    [user setObject:json[kContactFBId] forKey:kUserLinkedInId];
    [user setObject:@NO forKey:kUserImportedAllContacts];
    [user setObject:@[] forKey:kUserConnections];
    if (save) {
        [user saveInBackground];
    }
}


// generates tags based on Tag Options that are retrieved from Parse upon launch
// and
- (void)generateTags:(BOOL)pushToParse {
    FBManager *lim = [FBManager singleton];
    NSMutableArray *generated = [[NSMutableArray alloc] init];
    NSMutableDictionary *addedTags = [[NSMutableDictionary alloc] init];
    NSCharacterSet *badCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
    
    // go through all attributes and look for TagOptions
    // if there is a tag option, add it to the tags array for return.
    // before we return the array, send all of the attributes to parses
    NSArray *strings = [self getValidStrings];
    for (NSString *string in strings) {
        // make sure we don't deal with anything null or blank
        if (!string || string.length < 1) {
            continue;
        }
        
        for (NSString *word in [self cleanseString:string dirtySet:badCharSet]) {
            if (!word || word.length < 1 || addedTags[word] != nil) {
                continue;
            }
            addedTags[word] = @YES; // don't add tags twice
            TagOption *option = [lim.tagOptions objectForKey:word];
            if (option) {
                Tag *newTag = [Tag tagFromTagOption:option taggedUser:self.fbId byUser:[lim currenUserId]];
                [generated addObject:newTag];
            }
        }
    }
    
    if (pushToParse) {
        NSMutableArray *parseGenerated = [NSMutableArray arrayWithCapacity:generated.count];
        for (Tag *t in generated) {
            [parseGenerated addObject:[t pfObject]];
        }
        [PFObject saveAllInBackground:parseGenerated];
    }
    self.hasGeneratedTags = YES;
    self.tagData = [NSKeyedArchiver archivedDataWithRootObject:generated];
}

#pragma mark Tags Override setter
- (NSArray *)tags_ {
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.tagData];
}

- (void)setTags_:(NSArray *)tags_ {
    self.tagData = [NSKeyedArchiver archivedDataWithRootObject:tags_];
}

// Makes sure that there are no special characters include when we are looking
// to guess tags.
-(NSArray *)cleanseString:(NSString *)dirtyString dirtySet:(NSCharacterSet *)dirtySet {
    return [dirtyString componentsSeparatedByCharactersInSet:dirtySet];
}


- (void)tagsFromServerWitBlock:(void (^)(BOOL success))callback {
    FBManager *lim = [FBManager singleton];
    PFQuery *query = [PFQuery queryWithClassName:kTagClass];
    [query whereKey:kTagTaggedBy equalTo:[lim currenUserId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error getting tags %@", error);
            if (callback) callback(NO);
        } else {
            
            NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objects.count];
            for (PFObject *obj in objects) {
                [arr addObject:[Tag tagFromParse:obj]];
            }
            self.tags_ = arr;
            if (callback) callback(YES);
        }
    }];
}

@end
