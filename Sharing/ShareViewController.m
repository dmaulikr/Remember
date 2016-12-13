//
//  ShareViewController.m
//  Sharing
//
//  Created by Keeton on 11/13/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import "ShareViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CoreLocation/CoreLocation.h>
#import "RMAudio.h"
#import "RMView.h"
//#import "RMPhotoManager.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ShareViewController ()
<UITextFieldDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSMutableArray *titles;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *post;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UILabel *urlName;
@property (weak, nonatomic) IBOutlet UIView *bar;
@property (copy, nonatomic) NSURL *sharedURL;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) RMAudio *sound;
@property (strong, nonatomic) RMDataManager *manager;
@property bool hasPhoto;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) NSMutableArray *capturedImages;
@property (nonatomic) UIImagePickerController *imagePickerController;

@end

@implementation ShareViewController
@synthesize title;
@synthesize titles;
@synthesize textView;
@synthesize titleField;
@synthesize bar;

@synthesize capturedImages;

//  Okay, so I had to do some really cheatsy things in order to get
//  the status bar to appear correctly. The storyboard has a small
//  view to set the correct color and then when the keyboard is shown
//  and the view moves, the buttons and title are made invisible so
//  that the status bar appears to be solid. I know, cheatsy.

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap];
    
    UITapGestureRecognizer *photo = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                    action:@selector(showImagePickerFromTap)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    [self.imageView addGestureRecognizer:photo];
    
    _sound = [[RMAudio alloc] init];
    _manager = [[RMDataManager alloc] init];
    _image = [[UIImage alloc] init];
    
    RMView *corners = [RMView new];
    [corners createViewWithRoundedCornersWithRadius:10.0 andView:_imageView];
    
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePropertyList]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePropertyList options:nil completionHandler:^(NSDictionary *jsDict, NSError *error)
                {
                    dispatch_async(dispatch_get_main_queue(),
                    ^{
                        NSDictionary *jsPreprocessingResults = jsDict[NSExtensionJavaScriptPreprocessingResultsKey];
                        NSString *selectedText = jsPreprocessingResults[@"body"]; // webpage body
                        NSString *pageTitle = jsPreprocessingResults[@"title"]; // title
                        NSString *url = jsPreprocessingResults[@"URL"];
                        if ([selectedText length] > 0) {
                            _sharedURL = [NSURL URLWithString:url];
                            //NSLog(@"Original URL: %@",url);
                            self.textView.text = [NSString stringWithFormat:@"Web-page URL:\n%@\n%@",url,selectedText];
                        } else if ([pageTitle length] > 0) {
                            title = pageTitle;
                            self.urlName.text = title;
                            titleField.text = title;
                        }
                        if (error) {
                            NSLog(@"%@",error.description);
                        }
                    });
                }];
                break;
            }
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage])
            {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error)
                {
                  dispatch_async(dispatch_get_main_queue(), ^{
                        if (image)
                        {
                            _imageView.image = image;
                            _image = image;
                            [_imageView setContentMode:UIViewContentModeScaleAspectFit];
                            _hasPhoto = true;
                        }
                        else
                        {
                            _imageView.image = [UIImage imageNamed:@"Camera Thumb"];
                            [_imageView setContentMode:UIViewContentModeCenter];
                            _hasPhoto = false;
                        }
                        if (error) {
                            NSLog(@"%@",error.description);
                      }
                    });
                }];
                break;
            }
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePlainText])
            {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePlainText options:nil completionHandler:^(NSString *string, NSError *error)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         self.textView.text = string;
                         if (error) {
                             NSLog(@"%@",error.description);
                         }
                     });
                 }];
                break;
            }
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL])
            {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSString *string, NSError *error)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         self.textView.text = string;
                         if (error) {
                             NSLog(@"%@",error.description);
                         }
                     });
                 }];
                break;
            }
        }
    }
    [titleField setDelegate:self];
    [textView setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
    [UIView animateWithDuration:0.25 animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
    
    [self createKeyboardObservers];
    
    RMView *corners = [RMView new];
    [corners createViewWithRoundedCornersWithRadius:10.0 andView:textView];
    
    [self showNavigationTitle];
}

- (void)dismissKeyboard
{
    [textView resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [titleField resignFirstResponder];
    return NO;
}

- (IBAction)cancel:(id)sender {
    [UIView animateWithDuration:0.20 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        NSError *error = [NSError new];
        [self.extensionContext cancelRequestWithError:error];
    }];
    [self cancelPostSound];
}

- (IBAction)createNote:(id)sender {
    [self readFileContents:@"Notes"];
    
    [_manager writeDataContentsWithTitle:titleField.text
                                 author:@"Share Extension"
                                   body:self.textView.text];
    
    [titles addObject:titleField.text];
    [self writeFileContents:@"Notes"];
    if (_sharedURL) {
        [self writeURLContents:_sharedURL andName:titleField.text];
    }
    if (_hasPhoto)
    {
        //RMPhotoManager *photo = [[RMPhotoManager alloc] initWithView:self andFileName:titleField.text];
        //[photo writePicture:_image withName:titleField.text];
        //[self finishAndUpdate];
    }
    [self addItemToCoreSpotlight];
    [self sendPostSound];
    [UIView animateWithDuration:0.20 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
    }];
}

- (void)addItemToCoreSpotlight {
    CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:@"kUTTypeText"];
    attributeSet.title = titleField.text;
    attributeSet.contentDescription = textView.text;
    attributeSet.thumbnailData = [NSData dataWithData:UIImagePNGRepresentation([UIImage imageNamed:@"Spotlight"])];
    CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:titleField.text domainIdentifier:@"com.solarpepper" attributeSet:attributeSet];
    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[item] completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Indexing Error: %@",error);
        }
        else {
            //NSLog(@"Item successfully added to index...");
        }
    }];
}

# pragma mark - Data Management

- (void)writeFileContents:(NSString *)name {
    [_manager writeTableContentsFromArray:titles
                             containerID:@"group.com.solarpepper.Remember"
                                fileName:name];
}

- (void)readFileContents:(NSString *)name {
    [_manager readTableContentsFromContainerID:@"group.com.solarpepper.Remember"
                                     fileName:name];
    titles = _manager.loadedTitles;
}

- (void)writeURLContents:(NSURL *)url andName:(NSString *)name {
    [_manager writeURL:url title:name];
}

#pragma mark - Title Management

- (void)showNavigationTitle {
    UIImage *image = [UIImage imageNamed:@"Check Title"];
    UIImageView *imageBar = [[UIImageView alloc] initWithImage:image];
    [self.navBar.topItem setTitleView:imageBar];
    self.post.tintColor = [UIColor whiteColor];
    self.cancel.tintColor = [UIColor whiteColor];
    self.post.enabled = true;
    self.cancel.enabled = true;
}

- (void)hideNavigationTitle {
    UIView *view = [[UIView alloc] init];
    [self.navBar.topItem setTitleView:view];
    self.post.tintColor = [UIColor clearColor];
    self.cancel.tintColor = [UIColor clearColor];
    self.post.enabled = false;
    self.cancel.enabled = false;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputModeDidChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    // the keyboard is hiding reset the table's height
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [self showNavigationTitle];
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    // the keyboard is showing so resize the table's height
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.view.frame;
    frame.origin.y -= 40;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [self hideNavigationTitle];
    [UIView commitAnimations];
}

- (void)inputModeDidChange:(NSNotification *)notification
{
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [self hideNavigationTitle];
    [UIView commitAnimations];
}

# pragma mark - Audio Management

- (void)sendPostSound
{
    [_sound playSoundWithName:@"Complete" extension:@"caf"];
}

- (void)cancelPostSound
{
    [_sound playSoundWithName:@"Dismiss" extension:@"caf"];
}

# pragma mark - Photo Library Management

- (IBAction)showImagePickerForPhotoPicker:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
}

- (void)showImagePickerFromTap
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (self.imageView.isAnimating)
    {
        [self.imageView stopAnimating];
    }
    
    if (self.capturedImages.count > 0)
    {
        [self.capturedImages removeAllObjects];
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _imageView.image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self finishAndUpdate];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self cancelPostSound];
}

- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.imagePickerController = nil;
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    NSURL *cDocuments = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents"]];
    
    NSString *imageName = [[cDocuments path] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",textView.text]];
    NSData *imageData = UIImageJPEGRepresentation(_image, 1.0);
    [imageData writeToFile:imageName atomically:YES];
    [self sendPostSound];
}

@end
