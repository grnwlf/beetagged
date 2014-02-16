//
//  FBManager.h
//  Bees Chest
//
//  Created by Billy Irwin on 12/29/13.
//  Copyright (c) 2013 Arbrr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <CoreData/CoreData.h>
#import "Constants.h"
#import "Contact.h"
#import "TagOption.h"
#import "TagIndex.h"
#import "ViewController.h"

@interface FBManager : NSObject
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSMutableArray *searchArray;
@property (strong, nonatomic) NSMutableArray *filterArray;
@property (nonatomic) BOOL search;
@property (nonatomic) BOOL tagFilter;
@property (nonatomic, assign, readonly) BOOL hasContacts;
@property (nonatomic, strong) NSMutableDictionary *tagOptions;
@property (strong, nonatomic)  TagIndex *tagIndex;
@property (strong, nonatomic) Contact *currentParseUser;

@property (weak, nonatomic) ViewController *vc;

+ (FBManager*)singleton;

- (void)refreshContacts;
- (BOOL)loggedIn;
- (void)setToken:(NSString*)token;
- (NSString*)token;
- (void)setCurrentUser:(NSDictionary*)user;
- (NSString*)currentUser;
- (NSString *)currenUserId;
- (NSDictionary *)currentUserAsDictionary;
- (NSArray *)tagOptionsArray;
- (void)importContacts:(NSArray*)contacts cb:(void(^)(void))callback;
- (void)search:(NSString *)query;
- (void)saveContext;
- (void)clearDB;
- (void)fetchContacts;
- (void)filterForTags:(NSArray*)tags;
- (void)cacheParseUser:(PFUser*)user reformat:(BOOL)reformat;
- (void)fetchCurUser;
+ (void)reformatHometown:(NSMutableDictionary*)c;
+ (void)reformatWork:(NSMutableDictionary*)c;
+ (void)reformatEducation:(NSMutableDictionary*)c;



@end
