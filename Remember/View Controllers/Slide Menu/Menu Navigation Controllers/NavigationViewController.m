//
//  NavigationViewController.m
//  Remember
//
//  Created by Keeton on 10/12/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import "NavigationViewController.h"
#import "DetailViewController.h"

@interface NavigationViewController ()

@end

@implementation NavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentViewControllerWithName:(NSString *)name; {
    DetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"detailController"];
    detail.rememberTitle = name;
    self.viewControllers = @[detail];
    self.frostedViewController.contentViewController = self;
    [self.frostedViewController setLimitMenuViewSize:true];
    [self.frostedViewController setMenuViewSize:CGSizeMake(150, self.view.frame.size.height)];
}

@end
