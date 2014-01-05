//
//  Tag.h
//  
//
//  Created by Chris O'Neil on 1/5/14.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Tag : NSObject


@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *attributeName;
@property (nonatomic, strong) NSString *taggedBy;
@property (nonatomic, strong) NSString *tagUserId;
@property (nonatomic, strong) NSString *tagOptionId;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSDate *createdAt;

+ (Tag *)tagFromParse:(PFObject *)pfObject;

@end
