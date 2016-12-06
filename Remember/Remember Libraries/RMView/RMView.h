//
//  RMView.h
//  Remember
//
//  Created by Keeton on 3/2/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RMView : NSObject

/**
 Modifies an already existing UIView to have rounded corners with a specified radius.
 */
- (void)createViewWithRoundedCornersWithRadius:(float)radius andView:(UIView *)view;

@end
