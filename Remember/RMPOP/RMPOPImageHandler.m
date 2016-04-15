//
//  RMPOPImageHandler.m
//  Remember
//
//  Created by Keeton on 2/19/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import "RMPOPImageHandler.h"

@interface RMPOPImageHandler()

@property BOOL scaleUp;
@property (weak) RMPOPImageView *image;
@property (weak) UIView *superView;

typedef struct {
    CGFloat progress;
    CGFloat toValue;
    CGFloat currentValue;
} AnimationInfo;

@end

@implementation RMPOPImageHandler

- (void)addImageViewinView:(UIView *)view withImageView:(RMPOPImageView *)popImage andTitle:(NSString *)rememberTitle
{
    _superView = view;
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handlePan:)];
    UITapGestureRecognizer *scale = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(handleTaps:)];
    [scale setNumberOfTapsRequired:2];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    NSString *photoPath = [[containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/"]] path];
    NSString *imageName = [photoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",rememberTitle]];
    UIImage *image;
    if (![fileManager fileExistsAtPath:imageName]) {
        image = [UIImage imageNamed:@"Camera"];
        self.hasPhoto = false;
    } else {
        image = [UIImage imageWithContentsOfFile:imageName];
        self.hasPhoto = true;
    }
    NSLog(@"Has Photo? %i",self.hasPhoto);
    CGFloat width = roundf(image.size.width*0.25f);
    CGFloat height = roundf(image.size.height*0.25f);
    popImage = [[RMPOPImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    popImage.center = _superView.center;
    [popImage setImage:image];
    [popImage addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [popImage addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [popImage addGestureRecognizer:recognizer];
    [popImage addGestureRecognizer:scale];
    _image = popImage;
    
    POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.fromValue = @(0.0);
    anim.toValue = @(1.0);
    anim.duration = 0.25;
    [popImage pop_addAnimation:anim forKey:@"reveal"];
    [view addSubview:popImage];
    [self scaleDownView:popImage];
    _scaleUp = false;
}

- (BOOL)hasPhotoWithTitle:(NSString *)rememberTitle {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    NSString *photoPath = [[containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/"]] path];
    NSString *imageName = [photoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",rememberTitle]];
    UIImage *image;
    if (![fileManager fileExistsAtPath:imageName]) {
        image = [UIImage imageNamed:@"Camera"];
        return false;
    } else {
        image = [UIImage imageWithContentsOfFile:imageName];
        return true;
    }
}

- (void)touchDown:(UIControl *)sender {
    [self pauseAllAnimations:YES forLayer:sender.layer];
}

- (void)touchUpInside:(UIControl *)sender {
    AnimationInfo animationInfo = [self animationInfoForLayer:sender.layer];
    BOOL hasAnimations = sender.layer.pop_animationKeys.count;
    
    if (hasAnimations && animationInfo.progress < 0.98) {
        [self pauseAllAnimations:NO forLayer:sender.layer];
        return;
    }
    
    [sender.layer pop_removeAllAnimations];
    if (animationInfo.toValue == 1 || sender.layer.affineTransform.a == 1) {
        [self scaleDownView:sender];
        return;
    }
    [self scaleUpView:sender];
}

- (void)handleTaps:(UITapGestureRecognizer *)recognizer
{
    if (_scaleUp)
    {
        [self scaleDownView:_image];
        _scaleUp = false;
    }
    else
    {
        _scaleUp = true;
        [self scaleUpView:_image];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    //[self scaleDownView:recognizer.view];
    CGPoint translation = [recognizer translationInView:_superView];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:_superView];
    
    if(recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:_superView];
        
        POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
        positionAnimation.velocity = [NSValue valueWithCGPoint:velocity];
        positionAnimation.dynamicsTension = 10.f;
        positionAnimation.dynamicsFriction = 1.0f;
        positionAnimation.springBounciness = 12.0f;
        [recognizer.view.layer pop_addAnimation:positionAnimation forKey:@"layerPositionAnimation"];
    }
}

- (void)scaleUpView:(UIView *)view
{
    POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    positionAnimation.toValue = [NSValue valueWithCGPoint:_superView.center];
    [view.layer pop_addAnimation:positionAnimation forKey:@"layerPositionAnimation"];
    
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.5, 1.5)];
    scaleAnimation.springBounciness = 10.f;
    [view.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
}

- (void)scaleDownView:(UIView *)view
{
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(0.75, 0.75)];
    scaleAnimation.springBounciness = 10.f;
    [view.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
}

- (void)pauseAllAnimations:(BOOL)pause forLayer:(CALayer *)layer
{
    for (NSString *key in layer.pop_animationKeys) {
        POPAnimation *animation = [layer pop_animationForKey:key];
        [animation setPaused:pause];
    }
}

- (void)dismissViewFromSuperView {
    POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.fromValue = @(1.0);
    anim.toValue = @(0.0);
    anim.duration = 0.25;
    [_image pop_addAnimation:anim forKey:@"fade"];
    double delayInSeconds = anim.duration;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        //NSLog(@"Image removed from superview");
        [_image removeFromSuperview];
    });
}

- (AnimationInfo)animationInfoForLayer:(CALayer *)layer
{
    POPSpringAnimation *animation = [layer pop_animationForKey:@"scaleAnimation"];
    CGPoint toValue = [animation.toValue CGPointValue];
    CGPoint currentValue = [[animation valueForKey:@"currentValue"] CGPointValue];
    
    CGFloat min = MIN(toValue.x, currentValue.x);
    CGFloat max = MAX(toValue.x, currentValue.x);
    
    AnimationInfo info;
    info.toValue = toValue.x;
    info.currentValue = currentValue.x;
    info.progress = min / max;
    return info;
}

@end
