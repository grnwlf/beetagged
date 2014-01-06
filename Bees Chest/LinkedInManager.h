//
//  LinkedInManager.h
//  Bees Chest
//
//  Created by Billy Irwin on 12/29/13.
//  Copyright (c) 2013 Arbrr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LIALinkedInApplication.h>
#import <LIALinkedInHttpClient.h>
#import <Parse/Parse.h>
#import <CoreData/CoreData.h>
#import "Constants.h"
#import "Contact.h"
#import "TagOption.h"

@interface LinkedInManager : NSObject
@property (strong, nonatomic) LIALinkedInApplication *app;
@property (strong, nonatomic) LIALinkedInHttpClient *client;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSMutableArray *searchArray;
@property (nonatomic, assign, readonly) BOOL isSearching;
@property (nonatomic, assign, readonly) BOOL hasContacts;
@property (nonatomic, strong) NSMutableDictionary *tagOptions;

+ (LinkedInManager*)singleton;

- (void)refreshContacts;
- (BOOL)loggedIn;
- (void)setToken:(NSString*)token;
- (NSString*)token;
- (void)setCurrentUser:(NSDictionary*)user;
- (NSString*)currentUser;
- (NSString *)currenUserId;
- (NSDictionary *)currentUserAsDictionary;
- (NSArray *)tagOptionsArray;
- (void)importContacts:(NSArray*)contacts;


@end
