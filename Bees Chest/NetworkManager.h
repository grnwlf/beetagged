//
//  NetworkManager.h
//  Bees Chest
//
//  Created by Chris O'Neil on 2/15/14.
//  Copyright (c) 2014 Arbrr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tag.h"
#import "FBManager.h"

@interface NetworkManager : NSObject

+ (NetworkManager *)singleton;
- (void)getRanksForTags:(NSArray *)tags;

@end
