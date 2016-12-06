//
//  RMParallax.m
//  Remember
//
//  Created by Keeton on 4/19/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import "RMParallax.h"

@interface RMParallax ()
@property (nonatomic) float minimumValue;
@property (nonatomic) float maximumValue;
@property (nonatomic) bool iPhoneIsSupported;
@end

@implementation RMParallax

- (instancetype)init;
{
    self = [super init];
    if (self) {
        _minimumValue = -10;
        _maximumValue =  10;
    }
    return self;
}
/*
- (instancetype)initWithView:(UIView *)initView
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}
*/
- (void)setMaximumValue:(float)maximumValue; {
    if (maximumValue) {
    _maximumValue = maximumValue;
    } else {
        _maximumValue = 10;
    }
}

- (void)setMinimumValue:(float)minimumValue; {
    if (minimumValue) {
        _minimumValue = minimumValue;
    } else {
        _minimumValue = -10;
    }
}

- (bool)iPhoneIsSupported {
    CGSize deviceScreenSize = [[UIScreen mainScreen] bounds].size;
    if (deviceScreenSize.height == 480)
        return false; // device is <= iPhone 4S
    else
        return true; // device is > iPhone 4
}

- (void)addParallaxToView:(UIView *)view; {
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(_minimumValue);
    verticalMotionEffect.maximumRelativeValue = @(_maximumValue);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(_minimumValue);
    horizontalMotionEffect.maximumRelativeValue = @(_maximumValue);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    //if (_iPhoneIsSupported)
    [view addMotionEffect:group];
}

@end
