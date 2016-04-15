//
//  RMPhotoManager.h
//  Remember
//
//  Created by Keeton on 5/21/15.
//  Copyright (c) 2015 Solar Pepper Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMPhotoManager : NSObject

- (id)initWithView:(UIViewController *)initView andFileName:(NSString *)name;
- (void)setFileContainer:(NSString *)name;
- (void)writePicture:(UIImage *)file withName:(NSString *)name;

/**
 Select and save a photo from the camera roll
 User will be presented with image picker and
 prompted for permission to access is needed
 */

- (void)selectPhotoFromLibrary:(UIViewController *)viewController;

/**
 Select and save a photo from the live camera
 User will be presented with camera view and
 prompted for permission to access if needed
 */

- (void)selectPhotoFromCamera:(UIViewController *)viewController;

/**
 Load a picture from a file with a given name.
 Assumes the extension is .jpg because by default,
 all iOS camera and photo library images are .jpg's
 */

- (void)loadPicture:(UIImageView *)imageView withName:(NSString *)name;

@end
