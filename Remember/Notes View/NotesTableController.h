//
//  SecondViewController.h
//  Remember
//
//  Created by Keeton on 10/12/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface NotesTableController : UIViewController
<CLLocationManagerDelegate>
/**
 Accessable mainly for XCTests and read/write optimization.
 */
- (IBAction)showMenu;
- (void)performSegueFromNotification:(UNNotificationRequest *)notification;

@property (strong, nonatomic) NSMutableArray *titles;

@end
