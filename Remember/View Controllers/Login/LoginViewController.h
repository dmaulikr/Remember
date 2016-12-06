//
//  LoginViewController.h
//  Remember
//
//  Created by Keeton on 12/1/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

- (void)runExitLogin;
@property (strong, nonatomic) IBOutlet UITextField *authorField;
@property (strong, nonatomic) IBOutlet UIImageView *contactImage;

@end
