//
//  RMPhotoManager.m
//  Remember
//
//  Created by Keeton on 5/21/15.
//  Copyright (c) 2015 Solar Pepper Studios. All rights reserved.
//

#import "RMPhotoManager.h"

@interface RMPhotoManager ()
<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) UIViewController *view;
@property (copy, nonatomic) RMAudio *sound;
@property (weak, nonatomic) UIImage *image;
@property (copy, nonatomic) NSString *file;
@property (copy, nonatomic) NSString *container;

@end

@implementation RMPhotoManager

- (id)initWithView:(UIViewController *)initView andFileName:(NSString *)name {
    _sound = [RMAudio new];
    _view = initView;
    _file = name;
    return self;
}

- (void)setFileContainer:(NSString *)name {
    _container = [NSString stringWithString:name];
}

- (void)selectPhotoFromLibrary:(UIViewController *)viewController; {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)selectPhotoFromCamera:(UIViewController *)viewController; {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType; {
    
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    _imagePickerController.sourceType = sourceType;
    _imagePickerController.delegate = self;
    
    self.imagePickerController = _imagePickerController;
    [_view presentViewController:_imagePickerController animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker; {
    
    [_view dismissViewControllerAnimated:YES completion:NULL];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"MainPhoto"]];
    [self cancelActionSound];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info; {
    _image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self finishAndUpdate:_file];
}

- (void)writePicture:(UIImage *)file withName:(NSString *)name; {
    _image = file;
    [self finishAndUpdate:name];
}

- (void)finishAndUpdate:(NSString *)name; {
    
    [_view dismissViewControllerAnimated:YES completion:NULL];
    self.imagePickerController = nil;
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:_container];
    NSURL *cDocuments = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents"]];
    NSString *imageName = [[cDocuments path] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",_file]];
    NSData *imageData = UIImageJPEGRepresentation(_image, 1.0);
    [imageData writeToFile:imageName atomically:YES];
    
    imageName = [[cDocuments path] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",_file]];
    _image = [UIImage imageWithContentsOfFile:imageName];
    [self photoCompleteSound];
}

- (void)loadPicture:(UIImageView *)imageView withName:(NSString *)name; {
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:_container];
    NSURL *cDocuments = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents"]];
    
    NSString *imageName = [[cDocuments path] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",name]];
    imageView.image = [UIImage imageWithContentsOfFile:imageName];
}

- (void)photoCompleteSound; {
    /*Save Sound*/
    [_sound playSoundWithName:@"5" extension:@"caf"];
}

- (void)cancelActionSound; {
    /*Save Sound*/
    [_sound playSoundWithName:@"1" extension:@"caf"];
}

@end
