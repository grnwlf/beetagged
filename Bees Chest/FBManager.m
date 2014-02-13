//
//  FBManager.m
//  Bees Chest
//
//  Created by Billy Irwin on 12/29/13.
//  Copyright (c) 2013 Arbrr. All rights reserved.
//

#import "FBManager.h"

@interface FBManager()

@property (nonatomic, assign, readwrite) BOOL isSearching;
@property (nonatomic, assign, readwrite) BOOL hasContacts;
@property (strong, nonatomic, readwrite) NSFetchedResultsController *fetchedResultsController;

@end

@implementation FBManager
static FBManager *fb = nil;

+ (FBManager*)singleton {
    if (!fb) {
        fb = [[FBManager alloc] init];
    }
    return fb;
}

- (void)saveContext {
    for (Contact *c in self.fetchedResultsController.fetchedObjects) {
        [c save];
    }
    [self.managedObjectContext save:nil];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)refreshContacts {
    [self fetchContacts];
}

- (id)init {
    self = [super init];
    if (self) {
        self.tagIndex = [[TagIndex alloc] init];
        
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BeesChestData" withExtension:@"momd"];
        self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Tag.sqlite"];
        
        NSError *error = nil;
        self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        if (self.persistentStoreCoordinator != nil) {
            self.managedObjectContext = [[NSManagedObjectContext alloc] init];
            [self.managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        }
        self.isSearching = NO;
        self.searchArray = [[NSMutableArray alloc] init];
        self.hasContacts = NO;
        [self fetchTagOptions];
        self.tagFilter = NO;
        
        self.filterArray = [[NSMutableArray alloc] init];
    }
    return self;
}

// grab all of the contact options from the server
- (void)fetchTagOptions {
    PFQuery *query = [PFQuery queryWithClassName:kTagOptionClass];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error fetching TagOptions: %@", error);
            self.tagOptions = [@[] mutableCopy]; // set tag options to empty array
        } else {
            self.tagOptions = [NSMutableDictionary dictionaryWithCapacity:objects.count];
            for (PFObject *object in objects) {
                TagOption *t = [TagOption tagOptionFromParse:object];
                [self.tagOptions setObject:t forKey:[t.attributeName lowercaseString]];
            }
            NSLog(@"Tag options %@", self.tagOptions);
        }
    }];
}

- (void)reformatWorkFor:(NSMutableDictionary*)c {
    NSMutableArray *workArr = [[NSMutableArray alloc] init];
    NSLog(@"work");
    for (NSDictionary *workDict in c[kContactWork]) {
        NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
        if (workDict[kContactEmployer]) {
            d[kContactEmployer] = workDict[kContactEmployer][kContactName];
        }
        if (workDict[kContactPosition]) {
            d[kContactPosition] = workDict[kContactPosition][kContactName];
        }
        
        [workArr addObject:d];
    }
    [c removeObjectForKey:kContactWork];
    c[kContactWork] = workArr;
    
}

- (void)reformatEducation:(NSMutableDictionary*)c {
    NSMutableArray *eduArr = [[NSMutableArray alloc] init];
    NSLog(@"education");
    for (NSDictionary *eduDict in c[kContactEducation]) {
        NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
        if (eduDict[kContactSchool]) {
            d[kContactSchool] = eduDict[kContactSchool][kContactName];
        }
        if (eduDict[@"year"]) {
            d[@"year"] = eduDict[@"year"][kContactName];
        }
        
        if (eduDict[kContactType]) {
            d[kContactType] = eduDict[kContactType];
        }
        
        [eduArr addObject:d];
    }
    [c removeObjectForKey:kContactEducation];
    c[kContactEducation] = eduArr;
    
}

- (void)reformatHometown:(NSMutableDictionary*)c {
    if (c[kContactHometown]) {
        NSLog(@"reformat home");
        NSString *s = c[kContactHometown][kContactName];
        [c removeObjectForKey:kContactHometown];
        [c setObject:s forKey:kContactHometown];
    }
}

- (void)importContacts:(NSArray*)contacts cb:(void(^)(void))callback {
//    BOOL shouldSendTagsToParse = [[[PFUser user] objectForKey:kUserImportedAllContacts] boolValue];
    
//    - (void)importContacts:(NSArray*)contacts cb:(void(^)(void))callback {
    
    
    NSMutableArray *pfUsers = [NSMutableArray arrayWithCapacity:[contacts count]];
    for (int i = 0; i < 60; i++) {
        NSMutableDictionary *c = [[NSMutableDictionary alloc] initWithDictionary:contacts[i]];
        [self reformatWorkFor:c];
        [self reformatEducation:c];
        [self reformatHometown:c];
        [pfUsers addObject:c];
    }
    NSString *meId = [[PFUser currentUser] objectForKey:@"fbId"];
    
    NSLog(@"pfusers: %@", pfUsers);
    
    [self uploadContacts:pfUsers meId:meId from:0 to:60 cb:callback];
    
    
    
//    for (NSDictionary *c in contacts) {
//        Contact *contact = [Contact contactFromFB:c];
//        
//        [self.managedObjectContext save:nil];
//    }
}

- (void)uploadContacts:(NSArray*)contacts meId:(NSString*)meId from:(int)from to:(int)to cb:(void(^)(void))cb {
    NSLog(@"%i %i", from, contacts.count);
    if (from >= contacts.count) {
        
        [self fetchContacts];
        
        //store all user id's so we have access to them on login
        NSMutableArray *userIds = [[NSMutableArray alloc] init];
        for (Contact *c in self.fetchedResultsController.fetchedObjects) {
            [userIds addObject:c.parseId];
        }
        
        [[PFUser currentUser] setObject:userIds forKey:@"connections"];
        [[PFUser currentUser] saveInBackground];
        cb();
        return;
    }
    int end = to;
    if (end >= contacts.count) end = contacts.count;
    
    float val = (float)from / (float)contacts.count;
    [self.vc setProgress:val];
    
    NSLog(@"upload from %i to %i", from, end);
    NSRange range = NSMakeRange(from, end-from);
    NSIndexSet *set = [[NSIndexSet alloc] initWithIndexesInRange:range];
    NSArray *uploadUsers = [contacts objectsAtIndexes:set];

    [PFCloud callFunctionInBackground:@"batchUpload" withParameters:@{@"users" : uploadUsers, @"meId" : meId} block:^(id object, NSError *error) {
        for (PFObject *o in object) {
            Contact *c = [Contact contactFromUserModel:o];
        }
        [self.managedObjectContext save:nil];
        [self uploadContacts:contacts meId:meId from:to to:to+60 cb:cb];
    }];
}


// This function gives the sort descriptors that allow group the contacts by
// lastName and sort the contacts by lastName
- (NSArray *)getSortDescriptors {
    NSSortDescriptor *groupByLastName = [[NSSortDescriptor alloc] initWithKey:kContactGroupByLastName ascending:YES];
    NSSortDescriptor *sortByLastName = [[NSSortDescriptor alloc] initWithKey:kContactLastName ascending:YES];
    return @[groupByLastName, sortByLastName];
}

// This returns the predicate that doesn't get all of the private private
// users that linkedin doesn't allow you to grab.
- (NSPredicate *)getPredicate {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"first_name != %@ AND last_name != %@", @"private", @"private"];
    return predicate;
}


- (void)fetchContacts {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *desc = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self.managedObjectContext];
    [req setEntity:desc];
    [req setSortDescriptors:[self getSortDescriptors]];
    [req setPredicate:[self getPredicate]];
    NSError *error;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:req
                                     managedObjectContext:self.managedObjectContext
                                     sectionNameKeyPath:kContactGroupByLastName
                                     cacheName:kCacheAllContacts];
    
    BOOL success = [self.fetchedResultsController performFetch:&error];
    if (success) {
        self.hasContacts = YES;
        //[self createFakeTags];
        //[self printContacts];
        [self.tagIndex createIndex:self.fetchedResultsController.fetchedObjects];
        //[self.tagIndex printTagIndex];
        NSLog(@"The fetch from Core Data was succcessful");
    } else {
        NSLog(@"Error fetching contacts from Core Data: %@", [error localizedDescription]);
    }
}

- (void)createFakeTags {
    NSString *tagStr = @"iOS Android Rails Python Java C++ ";
//    Go JavaScript Rails HTML CSS C SQL Perl PHP Haml Node Sails Express MongoDB Postgres MySQL Oracle Assembly Sass Math Science English History Writing Web Design Frontend Backend Database FullStack Communications Law Enterpeneur Health Doctor Calc Trig Stats Psych CS CSE EECS Mechanical Medical Engineering A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 1 2 3 4 5 6 7 8 9";
    NSArray *fakeTags = [tagStr componentsSeparatedByString:@" "];
    int x = fakeTags.count;
    for (Contact *c in self.fetchedResultsController.fetchedObjects) {
        int r = rand() % x;
        int rank = rand() % 6;
        Tag *t = [Tag tagFromTagName:fakeTags[r] taggedUser:c.parseId byUser:[[PFUser currentUser] objectForKey:@"fbId"] withRank:rank];
        
        c.tags_ = [@{ t.attributeName : t } mutableCopy];
    }
}

- (void)printContacts {
    NSLog(@"=====================================================================");
    NSLog(@"Printing all %i contacts", self.fetchedResultsController.fetchedObjects.count);
    NSLog(@"=====================================================================");
    
    for (Contact *c in self.fetchedResultsController.fetchedObjects) {
        NSMutableString *tags = [[NSMutableString alloc] init];
        NSArray *keys = c.tags_.allKeys;
        for (NSString *k in keys) {
            Tag *t = c.tags_[k];
            [tags appendFormat:@" %@ %@ %i", k, t.attributeName, t.rank.integerValue];
        }
        NSLog(@"%@ : %@", c.name, tags);
    }
}


- (NSArray *)tagOptionsArray {
    NSMutableArray *tagOptions = [[NSMutableArray alloc] initWithCapacity:self.tagOptions.count];
    NSArray *keys = [self.tagOptions allKeys];
    
    for (NSString *key in keys) {
        [tagOptions addObject:self.tagOptions[key]];
    }
    return tagOptions;
}

- (void)setToken:(NSString*)token {
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kLIToken];
}

- (NSString*)token {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLIToken];
}

- (void)setCurrentUser:(NSDictionary *)user {
    [[NSUserDefaults standardUserDefaults] setObject:user forKey:kLICurUser];
}

- (NSString*)currentUser {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kLICurUser];
}

- (NSString *)currenUserId {
    NSDictionary *currentUser = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kLICurUser];
    return currentUser[kContactFBId];
}

- (NSDictionary *)currentUserAsDictionary {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kLICurUser];
}

- (void)search:(NSString *)query {
    if (query.length == 0) {
        self.search = false;
    } else {
        self.search = true;
        NSArray *words = [query componentsSeparatedByString:@" "];
        NSString *first, *second;
        NSPredicate *queryNames;
        first = words[0];
        if (words.count > 1) {
            second = words[1];
            queryNames = [NSPredicate predicateWithFormat:
                          @"(first_name BEGINSWITH[cd] %@ AND last_name BEGINSWITH[cd] %@) OR (first_name BEGINSWITH[cd] %@ AND last_name BEGINSWITH[cd] %@)", first, second, second, first];
        } else {
            queryNames = [NSPredicate predicateWithFormat:@"first_name BEGINSWITH[cd] %@ OR last_name BEGINSWITH[cd] %@", first, first];
        }
        NSArray *contacts = [self.fetchedResultsController fetchedObjects];
        self.searchArray = [contacts filteredArrayUsingPredicate:queryNames];
    }
}

- (void)filterForTags:(NSArray*)tags {
    if (tags.count == 0) {
        self.tagFilter = false;
        return;
    }
    
    NSArray *arr = [self.tagIndex contactsForTag:tags[0]];
    [self.filterArray removeAllObjects];
    for (int i = 0; i < arr.count; i++) {
        Contact *c = arr[i];
        [self.filterArray addObject:c];
        for (int j = 0; j < tags.count; j++) {
            NSString *t = tags[j];
            if (c.tags_[t] == nil) {
                [self.filterArray removeLastObject];
                break;
            }
        }
    }
    
    NSLog(@"%i, filterarry count", self.filterArray.count);
}


//deprecated with FB transition
//- (BOOL)loggedIn {
//    return [[NSUserDefaults standardUserDefaults] objectForKey:kLIToken] != nil;
//}

- (void)clearDB {
    for (Contact *c in self.fetchedResultsController.fetchedObjects) {
        [self.managedObjectContext deleteObject:c];
    }
    
    
    [NSFetchedResultsController deleteCacheWithName:kCacheAllContacts];
    self.fetchedResultsController = nil;
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (!error) {
        NSLog(@"Successfully deleted all contacts from Core Data");
    } else {
        NSLog(@"Error: %@ when attempting to delete all contacts from Core Data", [error localizedDescription]);
    }

}



@end