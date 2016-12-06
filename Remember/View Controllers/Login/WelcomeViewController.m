//
//  WelcomeViewController.m
//  Remember
//
//  Created by Keeton on 1/14/15.
//  Copyright (c) 2015 Solar Pepper Studios. All rights reserved.
//

#import "WelcomeViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "RMDataManager.h"
#import "RMPhotoManager.h"
#import "RMView.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import "RMPhotoManager.h"

@interface WelcomeViewController ()
<CLLocationManagerDelegate, GIDSignInDelegate, GIDSignInUIDelegate>
@property (copy, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;
@property (strong, nonatomic) UIWindow *window;
@property (copy, nonatomic) UIImage *image;
@property (copy, nonatomic) NSString *name;
@property (weak, nonatomic) IBOutlet UILabel *signInLabel;
@property (strong, nonatomic) RMPhotoManager *photo;

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*
     Just a note to self, I'm keeping this mess of a Google sign in here
     instead of moving it to RMGooglePlus because this is so unique due to the
     alerts and such for a first time login, it would be a pain to move it all
     and then rewrite this entire view. Besides, I'm not going to repeat this code either.
    */
    
    self.background.image = _imageName;
    self.tutorialText.text = self.text;
    self.tutorialText.textColor = _textColor;
    //[UIColor colorWithContrastingBlackOrWhiteColorOn:
    // [UIColor colorWithComplementaryFlatColorOf:
    //  AverageColorFromImage(_imageName)] isFlat:YES];
    self.signInLabel.textColor = _signinColor;
    //[UIColor colorWithContrastingBlackOrWhiteColorOn:
    //[UIColor colorWithComplementaryFlatColorOf:
    //AverageColorFromImage(_imageName)] isFlat:YES];
    
    RMView *corners = [RMView new];
    [corners createViewWithRoundedCornersWithRadius:10.0 andView:_blurView];
    
    _signIn = [GIDSignIn sharedInstance];
    _signIn.delegate = self;
    _signIn.uiDelegate = self;
    _signIn.shouldFetchBasicProfile = YES;
    //_signIn.allowsSignInWithWebView = YES;
    _signIn.clientID = @"262401164415-hqcftmico35rqpotenujfcbbrgl4uej6.apps.googleusercontent.com";
    _signIn.scopes = @[@"profile"];
    
    _image = [UIImage new];
    _photo = [[RMPhotoManager alloc] initWithView:self andFileName:@"MainPhoto"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if ([[GIDSignIn sharedInstance] hasAuthInKeychain])
    {
        //NSLog(@"User has signed in. Code: %@",error);
        // The user is signed in.
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.signInButton.hidden = YES;
        //NSString *userId = user.userID;                  // For client-side use only!
        //NSString *idToken = user.authentication.idToken; // Safe to send to the server
        //NSString *email = user.profile.email;
        GIDProfileData *profileData = user.profile;
        _name = user.profile.name;
        _image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[profileData imageURLWithDimension:250]]];
        [self finishAndUpdate];
        
        [defaults setObject:_name forKey:@"Default Author"];
        [defaults synchronize];
        
        float value = floorf((int)12);
        [defaults setFloat:value forKey:@"Text Size"];
        [defaults synchronize];
        
        //[self updateLocation];
        
        SCLAlertView *alert = [SCLAlertView new];
        alert.shouldDismissOnTapOutside = YES;
        alert.backgroundType = SCLAlertViewBackgroundBlur;
        [alert showCustom:self.window.rootViewController
                    image:[UIImage imageNamed:@"Sticky Note"]
                    color:[UIColor flatPurpleColorDark]
                    title:@"Login Successful"
                 subTitle:@"Remember has successfully logged into Google+. You may now customize your text size, photo or name."
         closeButtonTitle:@"Dismiss"
                 duration:10.0f];
    }
        else
    {
        SCLAlertView *alert = [SCLAlertView new];
        alert.shouldDismissOnTapOutside = YES;
        alert.backgroundType = SCLAlertViewBackgroundBlur;
        [alert showCustom:self
                    image:[UIImage imageNamed:@"Sticky Note"]
                    color:[UIColor flatPurpleColorDark]
                    title:@"Login Failed"
                 subTitle:@"Remember has failed to login you into Google+. Please complete the setup manually."
         closeButtonTitle:@"Dismiss"
                 duration:10.0f];
        self.signInButton.hidden = NO;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self continueSetup];
}

- (IBAction)dismissView:(id)sender {
    [self continueSetup];
}

- (void)continueSetup
{
    LoginViewController *login = [self.storyboard instantiateViewControllerWithIdentifier:@"loginController"];
    login.authorField.text = _name;
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    NSURL *cDocuments = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents"]];
    //NSLog(@"%@",cDocuments);
    NSString *imageName = [[cDocuments path] stringByAppendingPathComponent:[NSString stringWithFormat:@"MainPhoto.jpg"]];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"contactPhoto"])
    { // Look out for the !
        login.contactImage.image = [UIImage imageNamed:@"Default Avatar"];
    } else {
        login.contactImage.image = [UIImage imageWithContentsOfFile:imageName];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier:@"push" sender:nil];
}

- (IBAction)googlePlusSignIn:(id)sender {
    [[GIDSignIn sharedInstance] signIn];
}

#pragma mark - Photo Management

- (void)finishAndUpdate
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"MainPhoto"]];
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    NSURL *cDocuments = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents"]];
    NSString *imageName = [[cDocuments path] stringByAppendingPathComponent:[NSString stringWithFormat:@"MainPhoto.jpg"]];
    NSData *imageData = UIImageJPEGRepresentation(_image, 1.0);
    [imageData writeToFile:imageName atomically:YES];
    
    [self photoCompleteSound];
}

#pragma mark - Audio Management

- (void)photoCompleteSound {
    RMAudio *sound = [[RMAudio alloc] init];
    [sound playSoundWithName:@"5" extension:@"caf"];
}

- (void)cancelActionSound {
    RMAudio *sound = [[RMAudio alloc] init];
    [sound playSoundWithName:@"1" extension:@"caf"];
}

@end
