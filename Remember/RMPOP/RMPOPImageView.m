//
//  RMPOPImageView.m
//  Remember
//
//  Created by Keeton on 2/19/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import "RMPOPImageView.h"

@interface RMPOPImageView()
@property (nonatomic) UIImageView *imageView;
@end

@implementation RMPOPImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 5.f;
        self.layer.masksToBounds = YES;
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];
    }
    return self;
}

#pragma mark - Property Setters

- (void)setImage:(UIImage *)image
{
    [self.imageView setImage:image];
    _image = image;
}


@end
