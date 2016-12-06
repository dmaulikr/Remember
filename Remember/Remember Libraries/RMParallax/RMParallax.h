//
//  RMParallax.h
//  Remember
//
//  Created by Keeton on 4/19/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RMParallax : NSObject

- (instancetype)init;
- (void)setMaximumValue:(float)maximumValue;
- (void)setMinimumValue:(float)minimumValue;
- (void)addParallaxToView:(UIView *)view;

@end
