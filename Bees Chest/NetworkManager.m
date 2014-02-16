//
//  NetworkManager.m
//  Bees Chest
//
//  Created by Chris O'Neil on 2/15/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager

static NetworkManager *nw = nil;
+ (NetworkManager *)singleton {
    if (!nw) {
        nw = [[NetworkManager alloc] init];
    }
    return nw;
}

- (void)getRanksForTags:(NSArray *)tags {
    [self getTagsFromParse:tags];
}

- (void)getTagsFromParse:(NSArray *)tags {
    NSMutableArray *tagIds = [NSMutableArray arrayWithCapacity:tags.count];
    for (Tag *tag in tags) {
        [tagIds addObject:tag.objectId];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Tag"];
    [query whereKey:@"objectId" containedIn:tagIds];
    [query whereKey:kTagTaggedBy containedIn:[[PFUser currentUser] objectForKey:kUserConnections]];
    [query whereKey:kTagUserId containedIn:[[PFUser currentUser] objectForKey:kUserConnections]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"error doing network query %@", error);
        } else {
            NSLog(@"objects = %@", objects);
        }
    }];
}


@end
