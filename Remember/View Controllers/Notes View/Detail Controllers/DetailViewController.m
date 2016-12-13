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

#import "RMNote.h"
#import "RMNoteLoader.h"

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

@property (weak) IBOutlet UIImageView           *background;
@property (weak) IBOutlet UITextView            *textView;
@property (weak) IBOutlet UITextField           *authorField;
@property (weak) IBOutlet UITextField           *urlField;
@property (weak) IBOutlet UIButton              *dateButton;
@property (weak) IBOutlet UIButton              *paperclip;
@property (weak) IBOutlet UINavigationItem      *navigationItem;
@property (weak) IBOutlet UIImageView           *noteImageView;

@property (nonatomic) NSMutableArray            *capturedImages;
@property (nonatomic) NSString                  *photoPath;
@property (nonatomic) UIImagePickerController   *imagePickerController;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (copy, nonatomic) RMDataManager       *dataManager;
@property (copy, nonatomic) RMPhotoManager      *photoManager;
@property (copy, nonatomic) RMAudio             *audio;
@property (copy, nonatomic) RMSpotlight         *spotlight;
@property (weak, nonatomic) RMPOPImageView      *popImage;
@property (copy, nonatomic) RMPOPImageHandler   *popHandler;

@property (strong, nonatomic) RMNote            *note;
@property (strong, nonatomic) RMNoteLoader      *loader;

@end

@implementation DetailViewController
{
    BOOL showingKeyboard;
    BOOL showingPhoto;
    BOOL hasLocation;
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _note = [[RMNote alloc] init];
    
    _dataManager = [[RMDataManager alloc] init];
    _photoManager = [[RMPhotoManager alloc] initWithView:self andFileName:_rememberTitle];
    [_photoManager setFileContainer:@"group.com.solarpepper.Remember"];
    _audio = [RMAudio new];
    _spotlight = [RMSpotlight new];
    _popHandler = [RMPOPImageHandler new];
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
    
    UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(showPhoto)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    [_noteImageView addGestureRecognizer:photoTap];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]
                                        initWithTarget:self
                                                action:@selector(hideKeyboard)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipe];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _navigationItem.title = _rememberTitle;
    [self customizeText];
    [self createKeyboardObservers];
    [self readFileContents];
    if ([_authorField.text isEqualToString:@""])
    {
        _authorField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"RMAuthor"];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self writeFileContents];
    [self removeKeyboardObservers];
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
    if (_authorField.text == nil && [[NSUserDefaults standardUserDefaults] objectForKey:@"RMAuthor"])
    {
        _authorField.text = [NSString stringWithFormat:@"%@",[defaults valueForKey:@"RMAuthor"]];
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
}

- (void)removeKeyboardObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    showingKeyboard = false;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    showingKeyboard = true;
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
    _latitude = [NSNumber numberWithFloat:_locationManager.location.coordinate.latitude];
    _longitude = [NSNumber numberWithFloat:_locationManager.location.coordinate.longitude];
}

# pragma mark - Photo Library Management

- (IBAction)showImagePickerForPhotoPicker:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Action:"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    NSURL *url = [_dataManager readURL:_rememberTitle];
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"Photo From Library"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action)
                            {
                                [_photoManager selectPhotoFromLibrary:self];
                                //HNKCacheFormat *format = [HNKCache sharedCache];
                                //[format removeAllImages];
                            }];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Photo From Camera"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action)
                            {
                                [_photoManager selectPhotoFromCamera:self];
                                //HNKCache *format = [HNKCache sharedCache];
                                //[format removeAllImages];
                            }];
    
    UIAlertAction *viewPhoto = [UIAlertAction actionWithTitle:@"View Photo"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action)
                             {
                                 [_popHandler addImageViewinView:self.view withImageView:_popImage andTitle:_rememberTitle];
                                 showingPhoto = true;
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
                                  [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
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
    //if ([_imageHandler hasPhotoWithTitle:_rememberTitle]) { [alert addAction:viewPhoto]; }
    if (self.location) { [alert addAction:viewMap]; }
    if (url) { [alert addAction:viewURL]; }
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    [self writeFileContents];
}

- (void)showPhoto {
    [_popHandler addImageViewinView:self.view withImageView:_popImage andTitle:_rememberTitle];
    showingPhoto = true;
    [_textView setUserInteractionEnabled:NO];
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
    
    [_audio playSoundWithName:@"Complete" extension:@"caf"];
}

- (void)photoCompleteSound {
    
    [_audio playSoundWithName:@"Favorite" extension:@"caf"];
}

- (void)cancelActionSound {
    
    [_audio playSoundWithName:@"Dismiss" extension:@"caf"];
}

- (void)displayViewSound {
    
    [_audio playSoundWithName:@"Select" extension:@"caf"];
}

# pragma mark - Menu Management

- (IBAction)showMenu {
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController presentMenuViewController];
}

- (IBAction)dismissView:(id)sender {
    if (showingKeyboard)
    {
        [self hideKeyboard];
    }
    else if (showingPhoto)
    {
        [_popHandler dismissViewFromSuperView];
        [_textView setUserInteractionEnabled:YES];
        showingPhoto = false;
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
    [_note setName:_rememberTitle];
    [_note setAuthor:_authorField.text];
    [_note setBody:[[NSAttributedString alloc] initWithString:_textView.text attributes:nil]];
    [_note setUrl:[NSURL URLWithString:_urlField.text]];
    [_note setLocation:@[_latitude, _longitude]];
    [_note setImage:_noteImageView.image];
    // Save data we just set
    [_loader saveDataToDiskWithNote:_note];
    
    // Deprecated: To be removed
    [_dataManager writeDataContentsWithTitle:_rememberTitle
                                 author:_authorField.text
                                   body:_textView.text];
    [_dataManager writeCoordinatesWithLatitude:[_latitude floatValue] longitude:[_longitude floatValue]];
    // Still used: Do not remove
    [_spotlight addItemToCoreSpotlightWithName:_rememberTitle andDescription:_textView.text];
}

- (void)readFileContents {
    _note = [_loader loadDataFromDiskWithName:_rememberTitle];
    [_note debugNoteContents];
    
    // Deprecated: To be removed
    [_dataManager readDataContentsWithTitle:_rememberTitle
                           containerID:@"group.com.solarpepper.Remember"];
    _authorField.text = _dataManager.loadedAuthor;
    _textView.text = _dataManager.loadedBody;
    _photoPath = _dataManager.loadedPhotoPath;
    [_photoManager loadPicture:_noteImageView withName:_rememberTitle];
    
    _latitude = [NSNumber numberWithFloat:_dataManager.loadedLatitude];
    _longitude = [NSNumber numberWithFloat:_dataManager.loadedLongitude];
    // Still used: Do not remove
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
