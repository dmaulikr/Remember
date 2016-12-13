//
//  DetailViewController.h
//  Remember
//
//  Created by Keeton on 10/14/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

/**
 Accessable mainly for XCTests and read/write optimization.
 */
- (IBAction)showMenu;
- (void)writeFileContents;
- (void)readFileContents;

@property (strong, nonatomic) NSString          *rememberTitle;
@property (strong, nonatomic) NSDictionary      *plistData;

@property (nonatomic, assign) NSNumber          *latitude;
@property (nonatomic, assign) NSNumber          *longitude;
@property (strong, nonatomic) NSString          *reminder;
- (BOOL)location;

@end
