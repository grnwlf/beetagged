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
- (void)remove:(Contact*)contact forTag:(Tag*)tag;
- (BOOL)hasSameForTag:(Tag*)tag;
- (NSArray*)findTwoSameForTag:(Tag*)tag;
- (void)printRandomSame:(int)i;
- (Tag*)randomTag;
- (void)sortForTag:(Tag*)tag;


@end
