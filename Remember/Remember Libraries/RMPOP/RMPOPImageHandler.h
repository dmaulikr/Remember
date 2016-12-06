//
//  RMPOPImageHandler.h
//  Remember
//
//  Created by Keeton on 2/19/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMPOPImageView.h"

@interface RMPOPImageHandler : NSObject

- (void)addImageViewinView:(UIView *)view withImageView:(RMPOPImageView *)popImage andTitle:(NSString *)rememberTitle;
- (void)dismissViewFromSuperView;
@property (nonatomic) bool hasPhoto;
- (BOOL)hasPhotoWithTitle:(NSString *)rememberTitle;
@end
