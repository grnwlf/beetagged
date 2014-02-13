//
//  TagIndex.h
//  Bees Chest
//
//  Created by Billy Irwin on 1/20/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"
#import "Tag.h"

@interface TagIndex : NSObject

@property (strong, nonatomic) NSMutableDictionary *data;
@property (strong, nonatomic) NSMutableDictionary *sameTags;


- (void)createIndex:(NSArray*)contacts;
- (void)printTagIndex;
- (void)add:(Contact*)contact forTag:(Tag*)tag;
- (void)move:(Contact*)contact forTag:(Tag*)tag toIndex:(int)index;
- (void)remove:(Contact*)contact forTag:(Tag*)tag;
- (BOOL)hasSameForTag:(Tag*)tag;
- (NSArray*)findTwoSameForTag:(NSString*)tag;
- (void)printRandomSame:(int)i;
- (NSString*)randomTag;
- (void)sortForTag:(Tag*)tag;
- (int)countForTag:(Tag*)tag;
- (void)printForTag:(Tag*)t;
- (NSArray*)contactsForTag:(NSString*)tag;


@end
