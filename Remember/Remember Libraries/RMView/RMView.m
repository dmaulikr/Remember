//
//  RMView.m
//  Remember
//
//  Created by Keeton on 3/2/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import "RMView.h"

@implementation RMView

- (void)createViewWithRoundedCornersWithRadius:(float)radius andView:(UIView *)view; {
    CALayer * layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:radius];
}

@end
