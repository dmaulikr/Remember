//
//  DropboxController.m
//  Remember
//
//  Created by Keeton on 3/4/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import "DriveController.h"

@interface DriveController ()

@end

@implementation DriveController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    /*
    if ([[DBSession sharedSession] isLinked]) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        alert.shouldDismissOnTapOutside = YES;
        alert.backgroundType = Blur;
        [alert showCustom:self
                    image:[UIImage imageNamed:@"Dropbox"]
                    color:[UIColor colorWithHexString:@"#007ee5"]
                    title:@"Success!"
                 subTitle:@"Remember has successfully linked to your Dropbox account."
         closeButtonTitle:@"Dismiss"
                 duration:0.0f];
        [self dismissView:self];
    }
    */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dropboxLogin:(id)sender
{
    /*
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
     */
}

- (IBAction)dismissView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
