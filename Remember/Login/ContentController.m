//
//  ContentController.m
//  Remember
//
//  Created by Keeton on 2/12/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import "ContentController.h"
#import "WelcomeViewController.h"
#import "LoginViewController.h"

@interface ContentController ()
<UIPageViewControllerDataSource>
@property (weak, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (copy, nonatomic) NSArray *pageTitles;
@property (copy, nonatomic) NSArray *pageImages;
@end

@implementation ContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _pageTitles = @[@"Beautiful notes with the perfect features.",
                    @"Attach important photos and locations.",
                    @"Bookmark your favorites.",
                    @"Designed simply and beautifully for you."];
    _pageImages = @[[UIImage imageNamed:@"Pexels-1"],
                    [UIImage imageNamed:@"Pexels-2"],
                    [UIImage imageNamed:@"Pexels-3"],
                    [UIImage imageNamed:@"Pexels-4"]];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pageController"];
    self.pageViewController.dataSource = self;
    
    WelcomeViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (WelcomeViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    WelcomeViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"welcomeController"];
    pageContentViewController.imageName = self.pageImages[index];
    pageContentViewController.text = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((WelcomeViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((WelcomeViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
