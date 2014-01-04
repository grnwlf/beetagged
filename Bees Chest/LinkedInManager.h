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
#import <CoreData/CoreData.h>

@interface LinkedInManager : NSObject
@property (strong, nonatomic) LIALinkedInApplication *app;
@property (strong, nonatomic) LIALinkedInHttpClient *client;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSArray *contacts;

+ (LinkedInManager*)singleton;

- (NSArray*)getContacts;
- (BOOL)loggedIn;
- (void)setToken:(NSString*)token;
- (NSString*)token;
- (void)setCurrentUser:(NSDictionary*)user;
- (NSString*)currentUser;
- (void)importContacts:(NSArray*)contacts;


@end
