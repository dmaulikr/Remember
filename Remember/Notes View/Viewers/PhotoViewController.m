//
//  PhotoViewController.m
//  Remember
//
//  Created by Keeton on 11/4/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import "PhotoViewController.h"
#import "DetailViewController.h"
#import "RMView.h"

@interface PhotoViewController ()
<UIScrollViewDelegate>
@property (weak,nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) UIImage *image;
@property (copy) RMAudio *sound;
@property (copy) SCLAlertView *alert;
@property bool hasPhoto;

- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer;

@end

@implementation PhotoViewController
@synthesize scrollView;
@synthesize imageView;
@synthesize image;
@synthesize dismissButton;
@synthesize saveButton;
@synthesize rememberTitle;
@synthesize photoPath;
@synthesize alert;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    alert = [[SCLAlertView alloc] init];
    
    RMView *corners = [RMView new];
    [corners createViewWithRoundedCornersWithRadius:20.0 andView:scrollView];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    photoPath = [[containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/"]] path];
    NSString *imageName = [photoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",rememberTitle]];
    if (![fileManager fileExistsAtPath:imageName]) {
        image = [UIImage imageNamed:@"Camera Thumb"];
        _hasPhoto = false;
    } else {
        image = [UIImage imageWithContentsOfFile:imageName];
        _hasPhoto = true;
    }
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size = image.size};
    self.imageView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.contentSize = image.size;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.contentMode = UIViewContentModeCenter;
    
    self.scrollView.maximumZoomScale = 0.5f;
    self.scrollView.zoomScale = minScale;
    
    [self centerScrollViewContents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self dismissViewSound];
    [imageView setImage:nil];
    [imageView removeFromSuperview];
}

- (IBAction)savePhotoToLibrary:(id)sender {
    if (_hasPhoto)
    {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        alert.shouldDismissOnTapOutside = YES;
        alert.backgroundType = Blur;
        [alert showCustom:self
                    image:[UIImage imageNamed:@"Thin Check"]
                    color:[UIColor flatPurpleColorDark]
                    title:@"Success!"
                 subTitle:@"Remember has successfully saved your photo."
         closeButtonTitle:@"Dismiss"
                 duration:4.0f];
    }
    else
    {
        alert.shouldDismissOnTapOutside = YES;
        alert.backgroundType = Blur;
        [alert showCustom:self
                    image:[UIImage imageNamed:@"Thin Delete"]
                    color:[UIColor flatPurpleColorDark]
                    title:@"Error!"
                 subTitle:@"There is no photo attached to this note."
         closeButtonTitle:@"Dismiss"
                 duration:4.0f];
    }

}

#pragma mark - UIScrollView Managment

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    
    CGPoint pointInView = [recognizer locationInView:self.imageView];
    
    CGFloat newZoomScale = self.scrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
    
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that you want to zoom
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so you need to re-center the contents
    [self centerScrollViewContents];
}

#pragma mark - Audio Managment

- (void)dismissViewSound
{
    _sound = [[RMAudio alloc] init];
    [_sound playSoundWithName:@"1" extension:@"caf"];
}

@end
