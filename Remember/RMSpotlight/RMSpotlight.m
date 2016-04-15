//
//  RMSpotlight.m
//  Remember
//
//  Created by Keeton on 3/2/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import "RMSpotlight.h"

@implementation RMSpotlight
{
    
}
#pragma mark - Spotlight

//TODO: Move this to RMSpotlight in order to make this a bit more dynamic and usable in other applications

- (void)addItemToCoreSpotlightWithName:(NSString *)name andDescription:(NSString *)description; {
    CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:@"kUTTypeText"];
    attributeSet.title = name;
    attributeSet.contentDescription = description;
    attributeSet.thumbnailData = [NSData dataWithData:UIImagePNGRepresentation([UIImage imageNamed:@"Spotlight"])];
    CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:name domainIdentifier:@"com.solarpepper" attributeSet:attributeSet];
    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[item] completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Indexing Error: %@",error);
        }
        else {
            //NSLog(@"Item successfully added to index...");
        }
    }];
}

- (void)removeItemFromCoreSpotlightWithName:(NSString *)name; {
    [[CSSearchableIndex defaultSearchableIndex] deleteSearchableItemsWithIdentifiers:@[name] completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Failed to remove item from index with error: %@",error);
        }
        else {
            //NSLog(@"Item successfully removed from index...");
        }
    }];
}

@end
