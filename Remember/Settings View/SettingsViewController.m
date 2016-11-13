//
//  SettingsViewController.m
//  Remember
//
//  Created by Keeton on 10/13/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import "SettingsViewController.h"
#import "RMAudio.h"
#import <GoogleSignIn/GoogleSignIn.h>

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UISlider *textSizeSlider;
@property (weak, nonatomic) IBOutlet UILabel *textSizeLabel;
@property (weak, nonatomic) IBOutlet UITextField *defaultAuthorField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *signOut;
@property (weak, nonatomic) IBOutlet UISwitch *audioSwitch;
@property bool changingValue;

@end

@implementation SettingsViewController

# pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createPanGestureRecognizer];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                initWithTarget:self
                                        action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [self updateTextDemoSize];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _textSizeSlider.value = [defaults floatForKey:@"Text Size"];
    _textSizeLabel.text = [NSString stringWithFormat:@"Text Size: %g pt",[defaults floatForKey:@"Text Size"]];
    if (![defaults valueForKey:@"Default Author"])
    {
        _defaultAuthorField.text = [NSString stringWithFormat:@""];
        [defaults setObject:_defaultAuthorField.text forKey:@"Default Author"];
    }
    else
    {
        _defaultAuthorField.text = [NSString stringWithFormat:@"%@",[defaults valueForKey:@"Default Author"]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_audioSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"Audio"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark Gesture Management

- (void)createPanGestureRecognizer {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(panGestureRecognized:)];
    [self.view addGestureRecognizer:pan];
}

- (void)dismissKeyboard
{
    [_defaultAuthorField resignFirstResponder];
    [[NSUserDefaults standardUserDefaults] setObject:_defaultAuthorField.text forKey:@"Default Author"];
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    CGPoint velocity = [sender velocityInView:self.view];
    if (velocity.x > 0) {
        [self.frostedViewController panGestureRecognized:sender];
    }
}

# pragma mark - Menu Management

- (IBAction)showMenu
{
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController presentMenuViewController];
}

# pragma mark - Settings Management

- (IBAction)textSizeValueChanged:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float value = floorf((int)_textSizeSlider.value);
    [defaults setFloat:value forKey:@"Text Size"];
    _textSizeLabel.text = [NSString stringWithFormat:@"Text Size: %g pt",value];
    [defaults synchronize];
    [self updateTextDemoSize];
}

- (IBAction)authorValueChanged:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_defaultAuthorField.text forKey:@"Default Author"];
    [defaults synchronize];
}

- (IBAction)audioSwitchChanged:(id)sender {
    RMAudio *sound = [RMAudio new];
    if (_audioSwitch.isOn) {
        [[NSUserDefaults standardUserDefaults] setBool:_audioSwitch.isOn forKey:@"Audio"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [sound playSoundWithName:@"3" extension:@"caf"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:_audioSwitch.isOn forKey:@"Audio"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [sound playSoundWithName:@"3" extension:@"caf"];
    }
}

- (IBAction)deletePhoto:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    [alert addButton:@"Remove" actionBlock:^(void) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"contactPhoto"];
    }];
    
    alert.backgroundType = SCLAlertViewBackgroundBlur;
    [alert showTitle:self
               title:@"Remove Contact Photo"
            subTitle:@"Are you sure?\n(This cannot be undone.)"
               style:SCLAlertViewStyleWarning
    closeButtonTitle:@"Cancel"
            duration:0.00f];
}

#pragma mark - Google Sign In

- (IBAction)signOut:(id)sender {
    [[GIDSignIn sharedInstance] signOut];
    if ([[GIDSignIn sharedInstance] hasAuthInKeychain])
    {
        //NSLog(@"hasAuthInKeychain = TRUE");
        SCLAlertView *success = [SCLAlertView new];
        [success showCustom:self
                    image:[UIImage imageNamed:@"Default Avatar"]
                    color:[UIColor flatPurpleColorDark]
                    title:@"Signed Out"
                 subTitle:@"You have successfully disconnected Remember from Google+"
         closeButtonTitle:@"Dismiss"
                 duration:3.00f];
    }
        else
    {
        SCLAlertView *error = [SCLAlertView new];
        [error showCustom:self
                    image:[UIImage imageNamed:@"Default Avatar"]
                    color:[UIColor flatPurpleColorDark]
                    title:@"Sign Out Failed"
                 subTitle:@"Google+ was already disconnected."
         closeButtonTitle:@"Dismiss"
                 duration:3.00f];
    }
}

- (void)didDisconnectWithError:(NSError *)error {
    if (error) {
        NSLog(@"Received error %@", error);
        SCLAlertView *alert = [SCLAlertView new];
        [alert showTitle:@"Error"
                subTitle:error.description
                   style:SCLAlertViewStyleInfo
        closeButtonTitle:@"Dismiss"
                duration:0.00f];
    } else {
        SCLAlertView *alert = [SCLAlertView new];
        [alert showTitle:@"Signed Out"
                subTitle:@"You have been sucessfully signed out of Google."
                   style:SCLAlertViewStyleInfo
        closeButtonTitle:@"Dismiss"
                duration:3.00f];
    }
}

#pragma mark - Dropbox Sign In

- (IBAction)signOutDropbox:(id)sender {
    /*
    if ([[DBSession sharedSession] isLinked]) {
        SCLAlertView *success = [SCLAlertView new];
        [success showCustom:self
                      image:[UIImage imageNamed:@"Default Avatar"]
                      color:[UIColor flatPurpleColorDark]
                      title:@"Signed Out"
                   subTitle:@"You have successfully disconnected Remember from Dropbox"
           closeButtonTitle:@"Dismiss"
                   duration:3.00f];
        [[DBSession sharedSession] unlinkAll];
    } else {
        SCLAlertView *alert = [SCLAlertView new];
        [alert showCustom:self
                      image:[UIImage imageNamed:@"Default Avatar"]
                      color:[UIColor flatPurpleColorDark]
                      title:@"Sign Out Failed"
                   subTitle:@"Dropbox was already disconnected."
           closeButtonTitle:@"Dismiss"
                   duration:3.00f];
    }
    */
}

- (void)updateTextDemoSize {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [_textSizeLabel setFont:[UIFont fontWithName:@"Arimo" size:[defaults floatForKey:@"Text Size"]]];
}

- (IBAction)changeBackgroundImage:(id)sender {
    RMPhotoManager *pMan = [[RMPhotoManager alloc] initWithView:self andFileName:@"background"];
    [pMan setFileContainer:@"group.com.solarpepper.Remember"];
    [pMan selectPhotoFromLibrary:self];
}

- (IBAction)resetBackgroundImage:(id)sender {
    
}

@end
