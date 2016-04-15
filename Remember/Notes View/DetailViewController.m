//
//  DetailViewController.m
//  Remember
//
//  Created by Keeton on 10/14/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import "DetailViewController.h"
#import "NotesTableController.h"
#import "NavigationViewController.h"
#import "NotesTableCell.h"

#import "MapViewController.h"
#import "DateViewController.h"
#import "RMPOPImageView.h"
#import "RMPOPImageHandler.h"
#import "RMSpotlight.h"
#import "RMView.h"

@interface DetailViewController ()
<
MKMapViewDelegate,
CLLocationManagerDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIGestureRecognizerDelegate,
UITextFieldDelegate,
UITextViewDelegate
>

@property (weak) IBOutlet UIImageView *background;
@property (weak) IBOutlet UITextView *textView;
@property (weak) IBOutlet UITextField *authorField;
@property (weak) IBOutlet UIButton *dateButton;
@property (weak) IBOutlet UIButton *paperclip;
@property (weak) IBOutlet UINavigationItem *navigationItem;

@property (nonatomic) NSMutableArray *capturedImages;
@property (nonatomic) NSString *photoPath;
@property (nonatomic) UIImagePickerController *imagePickerController;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (copy, nonatomic) RMDataManager *manager;
@property (copy, nonatomic) RMPhotoManager *pMan;
@property (copy, nonatomic) RMAudio *sound;
@property (copy, nonatomic) RMSpotlight *spotlight;
@property (weak, nonatomic) RMPOPImageView *popImage;
@property (copy, nonatomic) RMPOPImageHandler *imageHandler;

@end

@implementation DetailViewController
{
    BOOL keyboard;
    BOOL photo;
    BOOL hasLocation;
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    _manager = [[RMDataManager alloc] init];
    _pMan = [[RMPhotoManager alloc] initWithView:self andFileName:_rememberTitle];
    [_pMan setFileContainer:@"group.com.solarpepper.Remember"];
    _sound = [RMAudio new];
    _spotlight = [RMSpotlight new];
    _imageHandler = [RMPOPImageHandler new];
    [_authorField setDelegate:self];
    [_textView setDelegate:self];
    
    _locationManager = [CLLocationManager new];
    [_locationManager setDelegate:self];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [_locationManager startUpdatingLocation];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                           action:@selector(hideKeyboard)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 2;
    [_textView addGestureRecognizer:tap];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]
                                        initWithTarget:self
                                                action:@selector(hideKeyboard)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipe];
    
    RMView *corners = [RMView new];
    [corners createViewWithRoundedCornersWithRadius:10.0 andView:_dateButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _navigationItem.title = _rememberTitle;
    [self customizeText];
    [self createKeyboardObservers];
    [self readFileContents];
    if ([_authorField.text isEqualToString:@""])
    {
        _authorField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"Default Author"];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self updateMapView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self writeFileContents];
    [self removeKeyboardObservers];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

# pragma mark - Custom Text Management

- (void)customizeText
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _textView.font = [UIFont fontWithName:@"Arimo" size:[defaults floatForKey:@"Text Size"]];
    _authorField.font = [UIFont fontWithName:@"Arimo" size:[defaults floatForKey:@"Text Size"]];
    [_textView setScrollEnabled:YES];
    [_textView setUserInteractionEnabled:YES];
    if (_authorField.text == nil && [[NSUserDefaults standardUserDefaults] objectForKey:@"Default Author"])
    {
        _authorField.text = [NSString stringWithFormat:@"%@",[defaults valueForKey:@"Default Author"]];
    }
    _textView.allowsEditingTextAttributes = NO;
}

# pragma mark - Keyboard Management

- (void)createKeyboardObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self
    //                                         selector:@selector(inputModeDidChange:)
    //                                             name:UIKeyboardWillChangeFrameNotification
    //                                           object:nil];
}

- (void)removeKeyboardObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self
    //                                                name:UIKeyboardWillChangeFrameNotification
    //                                              object:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // the keyboard is hiding reset the table's height
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSDictionary *keyboardInfo = [notification userInfo];
    NSValue *keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    CGRect text = self.textView.frame;
    text.size.height += (keyboardFrameBeginRect.size.height-40);
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.textView.frame = text;
    [UIView commitAnimations];
    keyboard = false;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    // the keyboard is showing so resize the table's height
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSDictionary *keyboardInfo = [notification userInfo];
    NSValue *keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    CGRect text = self.textView.frame;
    text.size.height -= (keyboardFrameBeginRect.size.height-40);
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.textView.frame = text;
    [UIView commitAnimations];
    keyboard = true;
}

- (void)inputModeDidChange:(NSNotification *)notification {
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSDictionary *keyboardInfo = [notification userInfo];
    NSValue *keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    CGRect text = self.textView.frame;
    text.size.height += (keyboardFrameBeginRect.size.height-40);
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.textView.frame = text;
    [UIView commitAnimations];
}

- (void)hideKeyboard {
    [_textView resignFirstResponder];
    [_authorField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)textFieldDidBeginEditing:(id)sender {
    
}

- (IBAction)textFieldDidEndEditing:(id)sender {
    _latitude = _locationManager.location.coordinate.latitude;
    _longitude = _locationManager.location.coordinate.longitude;
}

# pragma mark - Photo Library Management

- (IBAction)showImagePickerForPhotoPicker:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Action:"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    NSURL *url = [_manager readURL:_rememberTitle];
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"Photo From Library"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action)
                            {
                                [_pMan selectPhotoFromLibrary:self];
                                //HNKCache *format = [HNKCache sharedCache];
                                //[format removeAllImages];
                            }];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Photo From Camera"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action)
                            {
                                [_pMan selectPhotoFromCamera:self];
                                //HNKCache *format = [HNKCache sharedCache];
                                //[format removeAllImages];
                            }];
    UIAlertAction *viewPhoto = [UIAlertAction actionWithTitle:@"View Photo"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action)
                             {
                                 [_imageHandler addImageViewinView:self.view withImageView:_popImage andTitle:_rememberTitle];
                                 photo = true;
                                 [_textView setUserInteractionEnabled:NO];
                             }];
    UIAlertAction *viewMap = [UIAlertAction actionWithTitle:@"View Location"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action)
                             {
                                 [self showMapView:nil];
                             }];
    UIAlertAction *viewURL = [UIAlertAction actionWithTitle:@"View Webpage"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action)
                              {
                                  [[UIApplication sharedApplication] openURL:url];
                              }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * action)
    {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [library setValue:[[UIImage imageNamed:@"Flower"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [camera setValue:[[UIImage imageNamed:@"Camera Thumb"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [viewMap setValue:[[UIImage imageNamed:@"Location Thumb"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [viewPhoto setValue:[[UIImage imageNamed:@"Flower"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [viewURL setValue:[[UIImage imageNamed:@"World"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [alert addAction:library];
#if TARGET_IPHONE_SIMULATOR
    [alert addAction:camera];
    //NOTE: This will cause a crash on the simulator but I keep it in for image testing purposes.
#else
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [alert addAction:camera];
    }
#endif
    if ([_imageHandler hasPhotoWithTitle:_rememberTitle]) { [alert addAction:viewPhoto]; }
    if (self.location) { [alert addAction:viewMap]; }
    if (url) { [alert addAction:viewURL]; }
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    [self writeFileContents];
}

#pragma mark - Location

- (BOOL)location
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted ) {
        NSLog(@"Location services denied. Hiding maps option from menu.");
        return false;
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager startUpdatingLocation];
        NSLog(@"Location services unknown. Requesting permission.");
    }
    
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        NSLog(@"Location services allowed. Showing maps option in menu.");
        return true;
    }
    else { return false; }
}

#pragma mark - Audio Managment

- (void)saveNoteSound {
    
    [_sound playSoundWithName:@"3" extension:@"caf"];
}

- (void)photoCompleteSound {
    
    [_sound playSoundWithName:@"5" extension:@"caf"];
}

- (void)cancelActionSound {
    
    [_sound playSoundWithName:@"1" extension:@"caf"];
}

- (void)displayViewSound {
    
    [_sound playSoundWithName:@"2" extension:@"caf"];
}

# pragma mark - Menu Management

- (IBAction)showMenu {
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController presentMenuViewController];
}

- (IBAction)dismissView:(id)sender {
    if (keyboard)
    {
        [self hideKeyboard];
    }
    else if (photo)
    {
        [_imageHandler dismissViewFromSuperView];
        [_textView setUserInteractionEnabled:YES];
        photo = false;
    }
    else
    {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Add code here to do background processing
            [self writeFileContents];
            dispatch_async( dispatch_get_main_queue(), ^{
                // Add code here to update the UI/send notifications based on the
                // results of the background processing
                [self saveNoteSound];
                [self performSegueWithIdentifier:@"reversePushCell" sender:self];
            });
        });
    }
}

# pragma mark - Data Management

- (void)writeFileContents {
    [_manager writeDataContentsWithTitle:_rememberTitle
                                 author:_authorField.text
                                   body:_textView.text]; //date:_reminder];
    [_manager writeCoordinatesWithLatitude:_latitude longitude:_longitude];
    [_spotlight addItemToCoreSpotlightWithName:_rememberTitle andDescription:_textView.text];
}

- (void)readFileContents {
    [_manager readDataContentsWithTitle:_rememberTitle
                           containerID:@"group.com.solarpepper.Remember"];
    _authorField.text = _manager.loadedAuthor;
    _textView.text = _manager.loadedBody;
    _photoPath = _manager.loadedPhotoPath;
    _latitude = _manager.loadedLatitude;
    _longitude = _manager.loadedLongitude;
    [_spotlight removeItemFromCoreSpotlightWithName:_rememberTitle];
}

#pragma mark - Display Management

- (void)showMapView:(UIGestureRecognizer *)recognizer {
    [self performSegueWithIdentifier:@"mapPush" sender:self];
    [self writeFileContents];
}

- (void)showDateView {
    [self performSegueWithIdentifier:@"datePush" sender:self];
    [self writeFileContents];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"mapPush"])
    {
        MapViewController *segueController = segue.destinationViewController;
        segueController.rememberTitle = [NSString stringWithFormat:@"%@",_rememberTitle];
    }
    if ([segue.identifier isEqualToString:@"datePush"])
    {
        DateViewController *segueController = segue.destinationViewController;
        segueController.rememberTitle = [NSString stringWithFormat:@"%@",_rememberTitle];
        segueController.summary = [NSString stringWithFormat:@"%@",_textView.text];
    }
}

- (IBAction)showDateViewButton:(id)sender {
    [self showDateView];
}

@end
