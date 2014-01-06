//
//  Constants.h
//  Bees Chest
//
//  Created by Billy Irwin on 12/29/13.
//  Copyright (c) 2013 Arbrr. All rights reserved.
//

#ifndef Bees_Chest_Constants_h
#define Bees_Chest_Constants_h

//********************************************************************//
//    API Keys //
//********************************************************************//
#define kLinkedInAPIKey @"77pcrxxrn2lvoi"
#define kLinkedInSecretKey @"LVZyO08yHbJ4RCzI"
#define kLinkedInOAuthToken @"b1ddadf4-8640-4808-91c2-d6845952fd40"
#define kLinkedInOAuthSecret @"21705a65-f7c8-4fba-863c-bce7b7e51f64"
#define kLIToken @"litoken"
#define kLICurUser @"licuruser"

//********************************************************************//
//    UIView Frames //
//********************************************************************//
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

//********************************************************************//
//    StoryBoard Segues //
//********************************************************************//
#define kLoginSegue @"login"
#define kShowContactSegue @"ShowContact"

//********************************************************************//
//    ContactCell //
//********************************************************************//
#define kContactCell @"ContactCell"
#define kContactCellHeight 70.0
#define kContactCellPlaceholderImage [UIImage imageNamed:@"Bees Chest Placeholder.png"]

//********************************************************************//
//    Contact //
//********************************************************************//
#define kContactFirstName @"firstName"
#define kContactLastName @"lastName"
#define kContactFormattedName @"formattedName"
#define kContactHeadline @"headline"
#define kContactLinkedInId @"id"
#define kContactIndustry @"industry"
#define kContactPicUrl @"pictureUrl"
#define kContactLocation @"location"
#define kContactLocationName @"name"

// Position
#define kContactPosition @"positions"
#define kContactPositionValues @"values"
#define kContactPositionCompany @"company"
#define kContactPositionIndustry @"industry"
#define kContactPositionName @"name"
#define kContactPositionSize @"size"
#define kContactPositionIsCurrent @"isCurrent"
#define kContactPositionSummary @"summary"
#define kContactPositionTitle @"title"
#define kContactLinkedInGetUrl @"siteStandardProfileRequest"
#define kContactLinkedInUrl @"url"
#define kContactGroupByLastName @"groupByLastName"
#define kContactTagData @"tagData"


//********************************************************************//
//    Cache //
//********************************************************************//
#define kCacheAllContacts @"allContactsCache"

//********************************************************************//
//    Tags //
//********************************************************************//
#define kTagsNumberOfSections 3
#define kTagClass @"Tag"
#define kTagObjectId @"objectId"
#define kTagAttributeName @"attributeName"
#define kTagTaggedBy @"taggedBy"
#define kTagUserId @"userId"
#define kTagOptionId @"tagOptionId"
#define kTagCreatedAt @"createdAt"
#define kTagUpdatedAt @"updatedAt"

//********************************************************************//
//    Tag Option //
//********************************************************************//
#define kTagOptionClass @"TagOption"
#define kTagOptionAttributeName @"attributeName"
#define kTagOptionCreatedAt @"createdAt"
#define kTagOptionUpdatedAt @"updatedAt"


//********************************************************************//
//    User //
//********************************************************************//
#define kUserLinkedInId @"id"
#define kUserConnections @"connections"
#define kUserImportedAllContacts @"importedContacts"



#endif
