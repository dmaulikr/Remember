//
//  DateViewController.m
//  Remember
//
//  Created by Keeton on 11/4/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import "DateViewController.h"
#import "DetailViewController.h"
#import "RMView.h"

@interface DateViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker       *datePicker;
@property (weak, nonatomic) IBOutlet UIButton           *dateButton;
@property (weak, nonatomic) IBOutlet UIButton           *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton           *dismissButton;
@property (weak, nonatomic) IBOutlet UIView             *buttonBlur;
@property (weak, nonatomic) IBOutlet UILabel            *dateLabel;
@property (copy) RMAudio *sound;
@property (copy) SCLAlertView *alert;

@end

@implementation DateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sound = [[RMAudio alloc] init];
    
    [_datePicker setMinimumDate:[NSDate date]];
    [_datePicker setMinuteInterval:5];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateDateLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewSound];
}

- (IBAction)setReminder:(id)sender {
    [self scheduleLocalNotification];
}

- (IBAction)cancelReminder:(id)sender {
    [self cancelLocalNotification];
}

#pragma mark - Notifications Management

- (void)showConfirmation {
    _alert = [[SCLAlertView alloc] init];
    _alert.shouldDismissOnTapOutside = YES;
    _alert.backgroundType = SCLAlertViewBackgroundBlur;
    [_alert showCustom:self
                image:[UIImage imageNamed:@"Thin Check"]
                color:[UIColor flatPurpleColorDark]
                title:@"Success!"
             subTitle:@"Remember has successfully scheduled your reminder."
     closeButtonTitle:@"Dismiss"
             duration:4.0f];
    [_sound playSoundWithName:@"Complete" extension:@"caf"];
    
    RMDataManager *dataManager = [[RMDataManager alloc] init];
    [dataManager writeDates:self.datePicker.date title:self.rememberTitle];
    _alert = nil;
}

- (void)scheduleLocalNotification {
    // Set reminder for user
    NSDate *pickerDate = [self.datePicker date];
    
    // Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = pickerDate;
    localNotification.alertTitle = [NSString stringWithFormat:@"%@",_rememberTitle];
    localNotification.alertBody = _summary;
    localNotification.alertAction = @"Remember";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName = @"5.caf";
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:_rememberTitle forKey:@"ID"];
    localNotification.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    [self showConfirmation];
}

- (void)cancelLocalNotification {
    // Cancel reminder for user
    
    NSString *IDToCancel = _rememberTitle;
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    //UNNotificationRequest *notificationToCancel = nil;
    [center removePendingNotificationRequestsWithIdentifiers:@[IDToCancel]];
    
    _alert = [[SCLAlertView alloc] init];
    _alert.shouldDismissOnTapOutside = YES;
    _alert.backgroundType = SCLAlertViewBackgroundBlur;
    [_alert showCustom:self
                 image:[UIImage imageNamed:@"Thin Check"]
                 color:[UIColor flatPurpleColorDark]
                 title:@"Success!"
              subTitle:@"Remember has successfully cancelled your reminder."
      closeButtonTitle:@"Dismiss"
              duration:4.0f];
    [_sound playSoundWithName:@"Complete" extension:@"caf"];
    
    /*
    for(UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if([[notification.userInfo objectForKey:@"ID"] isEqualToString:IDToCancel]) {
            notificationToCancel = notification;
            [[UIApplication sharedApplication] cancelLocalNotification:notificationToCancel];
            _alert = [[SCLAlertView alloc] init];
            _alert.shouldDismissOnTapOutside = YES;
            //_alert.backgroundType = Blur;
            [_alert showCustom:self
                        image:[UIImage imageNamed:@"Thin Check"]
                        color:[UIColor flatPurpleColorDark]
                        title:@"Success!"
                     subTitle:@"Remember has successfully cancelled your reminder."
             closeButtonTitle:@"Dismiss"
                     duration:4.0f];
            [_sound playSoundWithName:@"Complete" extension:@"caf"];
            break;
        }
    }
    */
}

- (IBAction)pickerValueChanged:(id)sender {
    [self updateDateLabel];
}

- (void) updateDateLabel {
    //Updates the date label
    NSDate *pickerDate = [_datePicker date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy 'at' hh:mm"];
    NSString *format = [formatter stringFromDate:pickerDate];
    _dateLabel.text = [NSString stringWithFormat:@"%@",format];
}

#pragma mark - Audio Management

- (void)dismissViewSound
{
    [_sound playSoundWithName:@"Dismiss" extension:@"caf"];
}

@end
