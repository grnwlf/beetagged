//
//  LinkedInManager.m
//  Bees Chest
//
//  Created by Billy Irwin on 12/29/13.
//  Copyright (c) 2013 Arbrr. All rights reserved.
//

#import "LinkedInManager.h"

@interface LinkedInManager()

@property (nonatomic, assign, readwrite) BOOL isSearching;
@property (nonatomic, assign, readwrite) BOOL hasContacts;
@property (strong, nonatomic, readwrite) NSFetchedResultsController *fetchedResultsController;

@end

@implementation LinkedInManager

static LinkedInManager *li = nil;

+ (LinkedInManager*)singleton {
    if (!li) {
        li = [[LinkedInManager alloc] init];
    }
    return li;
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
        self.app = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.ancientprogramming.com"
                                                            clientId:kLinkedInAPIKey
                                                        clientSecret:kLinkedInSecretKey
                                                               state:@"DCEEFWF45453sdffef424"
                                                       grantedAccess:@[@"r_fullprofile", @"r_network"]];
        
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
            self.tagOptions = [NSMutableArray arrayWithCapacity:objects.count];
            for (PFObject *object in objects) {
                [self.tagOptions addObject:[TagOption tagOptionFromParse:object]];
            }
        }
    }];
}

- (void)importContacts:(NSArray*)contacts {
    for (NSDictionary *c in contacts) {
        Contact *contact = [Contact createContactFromLinkedIn:c];
        [self.managedObjectContext save:nil];
    }
}



// This function gives the sort descriptors that allow group the contacts by
// lastName and sort the contacts by lastName
-(NSArray *)getSortDescriptors {
    NSSortDescriptor *groupByLastName = [[NSSortDescriptor alloc] initWithKey:kContactGroupByLastName ascending:YES];
    NSSortDescriptor *sortByLastName = [[NSSortDescriptor alloc] initWithKey:kContactLastName ascending:YES];
    return @[groupByLastName, sortByLastName];
}

// This returns the predicate that doesn't get all of the private private
// users that linkedin doesn't allow you to grab.
-(NSPredicate *)getPredicate {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstName != %@ AND lastName != %@", @"private", @"private"];
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
        NSLog(@"The fetch from Core Data was succcessful");
    } else {
        NSLog(@"Error fetching contacts from Core Data: %@", [error localizedDescription]);
    }
}

- (void)saveContext
{
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

- (void)setToken:(NSString*)token
{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kLIToken];
}

- (NSString*)token
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLIToken];
}

- (void)setCurrentUser:(NSDictionary*)user
{
    [[NSUserDefaults standardUserDefaults] setObject:user forKey:kLICurUser];
}

- (NSString*)currentUser
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLICurUser];
}

- (BOOL)loggedIn
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLIToken] != nil;
}



@end
