//
//  AboutViewController.m
//  Remember
//
//  Created by Keeton on 10/19/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import "AboutViewController.h"
#import "RMView.h"

@interface AboutViewController ()
<MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UITextView *aboutText;
@property (weak, nonatomic) IBOutlet UIButton *mailButton;
@property (weak, nonatomic) IBOutlet UIButton *githubButton;
@property (weak, nonatomic) IBOutlet UIButton *safariButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

@end

@implementation AboutViewController
@synthesize aboutText;
@synthesize mailButton;
@synthesize githubButton;
@synthesize safariButton;
@synthesize twitterButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     Create Navigation Swipe Gesture
     */
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(panGestureRecognized:)];
    [self.view addGestureRecognizer:pan];
    [[RMView new] createViewWithRoundedCornersWithRadius:20.0 andView:aboutText];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Gesture Management

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

- (IBAction)showMenu {
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController presentMenuViewController];
}

# pragma mark - Mail Management

- (IBAction)mailButton:(id)sender {
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Remember Support Token"];
    [controller setToRecipients:@[@"keetonfeavel@outlook.com"]];
    [controller setMessageBody:@"Please use this contact form to suggest features, ask support a question or request more information." isHTML:NO];
    if (controller) [self presentViewController:controller animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - Button Management

- (IBAction)githubButton:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://github.com/Kfeavel"]];
}

- (IBAction)safariButton:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://kfeavel.github.io"]];
}

- (IBAction)twitterButton:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/Auxel_"]];
}

- (IBAction)efrainButton:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/EA_Roa"]];
}

@end
