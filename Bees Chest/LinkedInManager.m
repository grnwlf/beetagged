//
//  LinkedInManager.m
//  Bees Chest
//
//  Created by Billy Irwin on 12/29/13.
//  Copyright (c) 2013 Arbrr. All rights reserved.
//

#import "LinkedInManager.h"
#import "Constants.h"
#import "Contact.h"

#define kLIToken @"litoken"
#define kLICurUser @"licuruser"

@implementation LinkedInManager

static LinkedInManager *li = nil;

+ (LinkedInManager*)singleton
{
    if (!li) {
        li = [[LinkedInManager alloc] init];
    }
    return li;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSArray*)getContacts
{
    if (!self.contacts || self.contacts.count == 0) {
        [self fetchContacts];
    }
    
    return self.contacts;
}

- (id)init
{
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

    }
    return self;
}

- (void)importContacts:(NSArray*)contacts
{
    for (NSDictionary *c in contacts) {
        Contact *contact = [Contact createContactFromLinkedIn:c];
        [self.managedObjectContext save:nil];
    }
}

- (void)fetchContacts
{
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *desc = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self.managedObjectContext];
    [req setEntity:desc];
    NSError *error;
    self.contacts = [self.managedObjectContext executeFetchRequest:req error:&error];
    for (Contact *c in self.contacts) {
        [c loadImage];
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
