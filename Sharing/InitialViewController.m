//
//  InitialViewController.m
//  Remember
//
//  Created by Keeton on 2/3/15.
//  Copyright (c) 2015 Solar Pepper Studios. All rights reserved.
//

#import "InitialViewController.h"
#import "ShareViewController.h"

@interface InitialViewController ()

@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self performSegueWithIdentifier:@"pop" sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
