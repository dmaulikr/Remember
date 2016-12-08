//
//  RootViewController.m
//  Remember
//
//  Created by Keeton on 10/12/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
    /**
     Debug Font Names - Enable BOOLEAN below:
     */
    bool debugFonts = false; //[[NSUserDefaults standardUserDefaults] boolForKey:@"RMDebug"];
    if (debugFonts)
        for (NSString *familyName in [UIFont familyNames]) {
            for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
                NSLog(@"%@", fontName);
            }
        }
}

@end
