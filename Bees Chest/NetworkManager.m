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

// takes in a STRING of tags
- (void)getRanksForTagOptions:(NSArray *)tags {
    [self getTagsFromParse:tags];
}

- (void)getTagsFromParse:(NSArray *)tags {
    PFQuery *query = [PFQuery queryWithClassName:@"Tag"];
    [query whereKey:kTagAttributeName containedIn:tags];
//    [query whereKey:kTagTaggedBy containedIn:[[PFUser currentUser] objectForKey:kUserConnections]];
//    [query whereKey:kTagUserId containedIn:[[PFUser currentUser] objectForKey:kUserConnections]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"error doing network query %@", error);
        } else {
            NSLog(@"objects = %@", objects);
            
            for (PFObject *object in objects) {
                NSLog(@"%@, by %@", [object objectForKey:kTagAttributeName], [object objectForKey:kTagTaggedBy]);
            }
            
        }
    }];
}


@end
