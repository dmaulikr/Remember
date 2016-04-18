//
//  LoginViewController.m
//  Remember
//
//  Created by Keeton on 12/1/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import "LoginViewController.h"
#import "DropboxController.h"
#import "AppDelegate.h"
#import "RMView.h"

@interface LoginViewController ()
<CLLocationManagerDelegate>
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *address;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (copy, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;
@property (weak, nonatomic) IBOutlet UISlider *textSlider;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation LoginViewController
@synthesize imagePickerController;
@synthesize contactImage;
@synthesize authorField;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    RMView *corners = [RMView new];
    [corners createViewWithRoundedCornersWithRadius:10.0 andView:_blurView];
    [corners createViewWithRoundedCornersWithRadius:45.0 andView:self.contactImage];
    authorField.delegate = self;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(selectPhoto)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    [self.contactImage addGestureRecognizer:tap];
    [self showRequestLocation];
    [self updateLocation];
    [self loadPicture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showDropbox:(id)sender {
    DropboxController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"dropbox"];
    [self presentViewController:view animated:YES completion:nil];
}

- (IBAction)exitLogin:(id)sender {
    [self runExitLogin];
}

- (void)runExitLogin {
    NSString *storyboard;
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    if (iOSDeviceScreenSize.height == 480)
    {
        // Instantiate a new storyboard object using the storyboard file named Storyboard_iPhone35
        // Ugh. Apple, kill the iPhone 4S already!
        storyboard = @"iPhone-Small";
    }
    else
    {
        storyboard = @"Storyboard";
    }
    
    
    RMDataManager *dataManager = [[RMDataManager alloc] init];
    RMPhotoManager *photoManager = [[RMPhotoManager alloc] initWithView:self andFileName:@"Welcome"];
    [dataManager readTableContentsFromContainerID:@"group.com.solarpepper.Remember"
                                         fileName:@"Notes"];
    [dataManager writeDataContentsWithTitle:@"Welcome"
                                     author:@"Solar Pepper Studios"
                                       body:[NSString stringWithFormat:@"Welcome to Remember, the Smart Reminder App! Here are a few tips on how to use Remember:\n\nTo dismiss the keyboard, double tap the note’s text view.\n\nAdd a photo by tapping the paperclip above the text.\n\nThe text size and default author name can be changed any time in the settings.\n\nTo change your contact photo, tap on the current photo in the slide-out menu.\n\nView a larger map or photo by  tapping the paperclip above the note text and selecting the appropriate option.\n\nA reminder can be set by tapping the “Configure Reminder” button at the bottom of the screen."]];
    [photoManager setFileContainer:@"group.com.solarpepper.Remember"];
    [photoManager writePicture:[UIImage imageNamed:@"Welcome Banner"] withName:@"Welcome"];
    NSMutableArray *dictionary = dataManager.loadedTitles;
    [dictionary addObject:@"Welcome"];
    [dataManager writeTableContentsFromArray:dictionary
                                 containerID:@"group.com.solarpepper.Remember"
                                    fileName:@"Notes"];
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"Audio"];
    
    // Instantiate the initial view controller object from the storyboard
    // TODO: Remove? Does this cause issues?
    //[self dismissViewControllerAnimated:YES completion:nil];
    UIViewController *initialViewController;
    initialViewController = [[UIStoryboard storyboardWithName:storyboard bundle:nil] instantiateInitialViewController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = initialViewController;
    [self.window makeKeyAndVisible];
     
    //[self.storyboard instantiateViewControllerWithIdentifier:storyboard];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:authorField.text forKey:@"Default Author"];
    [defaults synchronize];
    
    return NO;
}

- (IBAction)sizeChanged:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float value = floorf((int)_textSlider.value);
    [defaults setFloat:value forKey:@"Text Size"];
    _textLabel.text = [NSString stringWithFormat:@"Text Size: %g pt",value];
    _textLabel.font = [UIFont fontWithName:@"Arimo" size:value];
    [defaults synchronize];
}

#pragma mark - Photo Management

- (void)selectPhoto {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"contactPhoto"];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"MainPhoto"]];
    [self cancelActionSound];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.contactImage.image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self finishAndUpdate];
}

- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.imagePickerController = nil;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"contactPhoto"]];
    
    NSString *photoPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imageName = [photoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"MainPhoto.jpg"]];
    NSData *imageData = UIImageJPEGRepresentation(self.contactImage.image, 1.0);
    [imageData writeToFile:imageName atomically:YES];
    
    photoPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    imageName = [photoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"MainPhoto.jpg"]];
    self.contactImage.image = [UIImage imageWithContentsOfFile:imageName];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self photoCompleteSound];
}

- (void)loadPicture
{
    NSString *photoPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imageName = [photoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"MainPhoto.jpg"]];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"contactPhoto"]) { // Look out for the !
        self.contactImage.image = [UIImage imageNamed:@"Default Avatar"];
    } else {
        self.contactImage.image = [UIImage imageWithContentsOfFile:imageName];
    }
    self.authorField.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"Default Author"];
}

#pragma mark - Location Management

- (void)showRequestLocation {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.shouldDismissOnTapOutside = YES;
    alert.backgroundType = Blur;
    [alert showCustom:self
                image:[UIImage imageNamed:@"Location Icon"]
                color:[UIColor flatPurpleColorDark]
                title:@"Location Permission"
             subTitle:@"Remember uses your location to determine where you wrote your notes and reminders.\nThis can be disabled in the settings."
     closeButtonTitle:@"Dismiss"
             duration:0.0f];
}

- (void)updateLocation
{
    _locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    self.locationManager.distanceFilter = 10.0f;
    
    //NSLog(@"Asking nicely for location permission.");
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted ) {
        return;
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager startUpdatingLocation];
    }
    
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager startUpdatingLocation];
    }
    
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager startUpdatingLocation];
}

#pragma mark - Audio Management

- (void)photoCompleteSound {
    /*Save Sound*/
    RMAudio *sound = [[RMAudio alloc] init];
    [sound playSoundWithName:@"5" extension:@"caf"];
}

- (void)cancelActionSound {
    /*Save Sound*/
    RMAudio *sound = [[RMAudio alloc] init];
    [sound playSoundWithName:@"1" extension:@"caf"];
}

@end
