//
//  WelcomeViewController.h
//  Remember
//
//  Created by Keeton on 1/14/15.
//  Copyright (c) 2015 Solar Pepper Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController
@property (assign, nonatomic) NSInteger pageIndex;
@property (strong, nonatomic) NSString *text;
@property (copy, nonatomic) UIColor *textColor;
@property (copy, nonatomic) UIColor *signinColor;
@property (strong, nonatomic) UIImage *imageName;
@property (strong, nonatomic) GIDSignIn *signIn;
@property (strong, nonatomic) IBOutlet UIImageView *background;
@property (strong, nonatomic) IBOutlet UILabel *tutorialText;
@end
