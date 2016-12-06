//
//  RMSpotlight.h
//  Remember
//
//  Created by Keeton on 3/2/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMSpotlight : NSObject
/**
 Adds an item to Springboard's Spotlight using a name (unique identifier) and description (preview of content).
 */
- (void)addItemToCoreSpotlightWithName:(NSString *)name andDescription:(NSString *)description;

/**
 Removes an item from Springboard's Spotlight using a name (unique identifier).
 */
- (void)removeItemFromCoreSpotlightWithName:(NSString *)name;

@end
