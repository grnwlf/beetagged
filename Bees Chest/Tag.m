//
//  Tag.m
//  
//
//  Created by Chris O'Neil on 1/5/14.
//
//

#import "Tag.h"

@implementation Tag


+ (Tag *)tagFromParse:(PFObject *)pfObject {
    Tag *tag = [[Tag alloc] init];
    tag.objectId = [pfObject objectId];
    tag.attributeName = [pfObject objectForKey:kTagAttributeName];
    tag.taggedBy = [pfObject objectForKey:kTagTaggedBy];
    tag.tagUserId = [pfObject objectForKey:kTagUserId];
    tag.tagOptionId = [pfObject objectForKey:kTagOptionId];
    tag.createdAt = [pfObject objectForKey:kTagCreatedAt];
    tag.updatedAt = [pfObject objectForKey:kTagUpdatedAt];
    return tag;
}

@end
