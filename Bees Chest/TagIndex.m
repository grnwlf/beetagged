//
//  TagIndex.m
//  Bees Chest
//
//  Created by Billy Irwin on 1/20/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import "TagIndex.h"

@implementation TagIndex

- (id)init
{
    self = [super init];
    if (self) {
        self.data = [[NSMutableDictionary alloc] init];
        self.sameTags = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)createIndex:(NSArray *)contacts
{
    [self.data removeAllObjects];
    for (Contact *c in contacts) {
        NSArray *keys = c.tags_.allKeys;
        for (NSString *t in keys) {
            [self add:c forTag:c.tags_[t]];
        }
    }
}

- (void)add:(Contact*)contact forTag:(Tag *)tag {
    if (self.data[tag.attributeName] == nil) {
        self.data[tag.attributeName] =  [[NSMutableArray alloc] init];
    }
    [self.data[tag.attributeName] addObject:contact];
    [self sortForTag:tag];
    
    [self hasSameForTag:tag];
}

- (BOOL)hasSameForTag:(Tag*)tag {
    int tmp = -1;
    for (Contact *c in self.data[tag.attributeName]) {
        Tag *t = c.tags_[tag.attributeName];
        if (tmp == [t.rank integerValue]) {
            self.sameTags[t.attributeName] = t;
            return true;
        } else {
            tmp = [t.rank integerValue];
        }
    }
    if (self.sameTags[tag.attributeName] != nil) {
        [self.sameTags removeObjectForKey:tag.attributeName];
    }
    return NO;
}

- (NSArray*)findTwoSameForTag:(Tag *)tag {
    int tmp = -1;
    int i = 0;
    Contact *tmpC;
    for (Contact *c in self.data[tag.attributeName]) {
        Tag *t = c.tags_[tag.attributeName];
        if (tmp == [t.rank integerValue]) {
            return @[c, tmpC];
        } else {
            tmp = [t.rank integerValue];
            tmpC = c;
        }
        i++;
    }
    NSLog(@"no same two contacts were found");
    if (self.sameTags[tag.attributeName] != nil) {
        [self.sameTags removeObjectForKey:tag.attributeName];
    }
    return @[];
}

- (void)sortForTag:(Tag*)tag {
    NSMutableArray *arr = self.data[tag.attributeName];
    [arr sortWithOptions:nil usingComparator:^NSComparisonResult(id obj1, id obj2) {
        Tag *t1 = [[(Contact*)obj1 tags_] objectForKey:tag.attributeName];
        Tag *t2 = [[(Contact*)obj2 tags_] objectForKey:tag.attributeName];
        return [t1.rank compare:t2.rank];
    }];
}

- (void)printTagIndex {
    NSArray *keys = [self.data allKeys];
    for (NSString *k in keys) {
        NSMutableString *str = [[NSMutableString alloc] init];
        for (Contact *c in self.data[k]) {
            Tag *t = c.tags_[k];
            [str appendFormat:@"%@ %i, ", c.name, t.rank.integerValue];
        }
        
        NSLog(@"%@    %@", k, str);
    }
}

- (Tag*)randomTag {
    NSArray *allTags = self.sameTags.allKeys;
    return self.sameTags[allTags[rand() % allTags.count]];
}

- (void)printRandomSame:(int)i {
    NSLog(@"printing random contacts");
    NSArray *keys = self.sameTags.allKeys;
    while (i > 0) {
        Tag *tag = self.sameTags[keys[rand()%keys.count]];
        NSLog(@"%@", tag.attributeName);
        NSArray *p = [self findTwoSameForTag:tag];
        Contact *c = p[0];
        Tag *t = c.tags_[tag.attributeName];
        Contact *c2 = p[1];
        Tag *t2 = c2.tags_[tag.attributeName];
        NSLog(@"%@ %@ %@ %i %@ %@ %i", tag.attributeName, c.first_name, c.last_name, t.rank.integerValue, c2.first_name, c2.last_name, t2.rank.integerValue );
        i--;
        
    }
}

@end
