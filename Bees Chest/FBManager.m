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
        }
    }];
}

- (void)importContacts:(NSArray*)contacts {
//    BOOL shouldSendTagsToParse = [[[PFUser user] objectForKey:kUserImportedAllContacts] boolValue];
    for (NSDictionary *c in contacts) {
        Contact *contact = [Contact contactFromFB:c];
        //[contact generateTags:YES]; // generate tags upon launch
        [self.managedObjectContext save:nil];
    }
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
        [self createFakeTags];
        [self printContacts];
        [self.tagIndex createIndex:self.fetchedResultsController.fetchedObjects];
        [self.tagIndex printTagIndex];
        [self.tagIndex printRandomSame:20];
        NSLog(@"The fetch from Core Data was succcessful");
    } else {
        NSLog(@"Error fetching contacts from Core Data: %@", [error localizedDescription]);
    }
}

- (void)createFakeTags {
    NSString *tagStr = @"iOS Android Ruby Python Java C++ Go JavaScript Rails HTML CSS C SQL Perl PHP Haml Node Sails Express MongoDB Postgres MySQL Oracle Assembly Sass Math Science English History Writing Web Design Frontend Backend Database FullStack Communications Law Enterpeneur Health Doctor Calc Trig Stats Psych CS CSE EECS Mechanical Medical Engineering A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 1 2 3 4 5 6 7 8 9";
    NSArray *fakeTags = [tagStr componentsSeparatedByString:@" "];
    int x = fakeTags.count;
    for (Contact *c in self.fetchedResultsController.fetchedObjects) {
        int r = rand() % x;
        int rank = rand() % 10;
        Tag *t = [Tag tagFromTagName:fakeTags[r] taggedUser:@"dsfadsfa" byUser:[FBManager singleton].currenUserId withRank:rank];
        
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

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
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


//deprecated with FB transition
//- (BOOL)loggedIn {
//    return [[NSUserDefaults standardUserDefaults] objectForKey:kLIToken] != nil;
//}



@end
