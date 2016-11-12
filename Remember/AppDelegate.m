//
//  AppDelegate.m
//  Remember
//
//  Created by Keeton on 10/11/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "NavigationViewController.h"
#import "RootViewController.h"
#import "MenuViewController.h"

@interface AppDelegate ()
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) RMGooglePlus *gPlus;

@end

@implementation AppDelegate
@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // Create content and menu controllers.
    _kClientId = @"262401164415-hqcftmico35rqpotenujfcbbrgl4uej6.apps.googleusercontent.com";
    /*
    DBSession *dbSession = [[DBSession alloc]
                            initWithAppKey:@"430jqxkfolcr5hl"
                            appSecret:@"bjdhe5a0jbxusch"
                            root:kDBRootAppFolder];
    [DBSession setSharedSession:dbSession];
    */
    
    // Handle open from local notification and execute action.
    NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo)
    {
        [self processRemoteNotification:userInfo];
    }
    else
    {
        application.applicationIconBadgeNumber = 0;
        [self initializeStoryBoardBasedOnScreenSize:nil];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    [self initializeHolidaySurprise];
    
    /* CHANGED */
    //application.applicationIconBadgeNumber = 0;
    /*
    [[Harpy sharedInstance] setAppID:@"931575516"];
    [[Harpy sharedInstance] setPresentingViewController:_window.rootViewController];
    [[Harpy sharedInstance] setAlertControllerTintColor:[UIColor flatPurpleColorDark]];
    [[Harpy sharedInstance] setAppName:@"Remember"];
    [[Harpy sharedInstance] setAlertType:HarpyAlertTypeOption];
    [[Harpy sharedInstance] setPatchUpdateAlertType:HarpyAlertTypeSkip];
    [[Harpy sharedInstance] setMinorUpdateAlertType:HarpyAlertTypeOption];
    [[Harpy sharedInstance] setMajorUpdateAlertType:HarpyAlertTypeForce];
    [[Harpy sharedInstance] checkVersion];
    */
    // Move all photos in Documents directory into the shared container directory. The only reason this (really) still exists is because I'm too lazy to update the share extension and because due to the nature of the end user, they will avoid updating Remember for a long while, which makes "legacy code" still necessary in order for the app to not continually fail to load data.
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    NSURL *cDocuments = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents"]];
    NSString *extension = @"jpg";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *fileName;
    while ((fileName = [e nextObject])) {
        if ([[fileName pathExtension] isEqualToString:extension])
        {
            [[NSFileManager defaultManager] moveItemAtPath:[documentsDirectory stringByAppendingPathComponent:fileName] toPath:[[cDocuments path] stringByAppendingPathComponent:fileName] error:nil];
        }
    }
    
    // Sign in at application launch
    [_gPlus signInAndRefreshInterface];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AdvLog"])
    {
        NSArray *newContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[cDocuments path] error:nil];
        NSLog(@"Files in Container: %@",newContents);
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    //check if your activity has type search action(i.e. coming from spotlight search)
    if ([userActivity.activityType isEqualToString:CSSearchableItemActionType ] == YES) {
        //the identifier you'll use to open specific views and the content in those views.
        NSString * identifierPath = [NSString stringWithFormat:@"%@",[userActivity.userInfo objectForKey:CSSearchableItemActivityIdentifier]];
        if (identifierPath != nil) {
            [self initializeStoryBoardBasedOnScreenSize:identifierPath];
            return YES;
        }
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    /*
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
        }
        return YES;
    }
    */
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *)options {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

#pragma mark - Local Notification Configuration

- (void)registerForNotifications {
    // Register for local and push notifications
    UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                    UIUserNotificationTypeSound|
                                    UIUserNotificationTypeBadge);
    
    UIUserNotificationSettings *settings;
    settings = [UIUserNotificationSettings settingsForTypes:types
                                                 categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    
    [self processRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    application.applicationIconBadgeNumber = 0;
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.alertAction
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    NSDictionary *dict = [notification userInfo];
    [self processRemoteNotification:dict];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
}

- (void)processRemoteNotification:(NSDictionary *)userInfo
{
    NSString *name = [userInfo objectForKey:@"Title"];
    //application.applicationIconBadgeNumber = 0;
    [self initializeStoryBoardBasedOnScreenSize:name];
}

#pragma mark - Holiday Awesomeness Stuff

- (void)initializeHolidaySurprise {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                    | NSCalendarUnitMonth
                                    | NSCalendarUnitHour
                                    | NSCalendarUnitMinute
                                               fromDate:[NSDate date]];
    NSInteger day = [components day];
    NSInteger month = [components month];
    NSMutableArray *dictionary = [[NSMutableArray alloc] init];
    RMDataManager *dataManager = [[RMDataManager alloc] init];
    [dataManager readTableContentsFromContainerID:@"group.com.solarpepper.Remember"
                                         fileName:@"Notes"];
    if (month == 12 && day == 25 && ![dictionary containsObject:@"Merry Christmas!"])
    {
        [dataManager writeDataContentsWithTitle:@"Merry Christmas!"
                                         author:@"Solar Pepper Studios"
                                           body:@"The Solar Pepper Studios team wishes you a merry Christmas and a happy New Year!"
                                           ];
        
        dictionary = dataManager.loadedTitles;
        [dictionary addObject:@"Merry Christmas!"];
        [dataManager writeTableContentsFromArray:dictionary
                                     containerID:@"group.com.solarpepper.Remember"
                                        fileName:@"Notes"];
    }
}

#pragma mark - Storyboard Initialization

- (void)initializeStoryBoardBasedOnScreenSize:(NSString *)controller {
    UIStoryboard *storyboard;
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"wasLaunchedBefore"])
    {
        if (iOSDeviceScreenSize.height == 480)
        {
            // Instantiate a new storyboard object using the storyboard file named Storyboard_iPhone35
            storyboard = [UIStoryboard storyboardWithName:@"iPhone-Small" bundle:nil];
        }
        else
        {
            storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        }
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wasLaunchedBefore"];
        if (iOSDeviceScreenSize.height == 480)
        {
            // Instantiate a new storyboard object using the storyboard file named Storyboard_iPhone35
            storyboard = [UIStoryboard storyboardWithName:@"Login-Universal" bundle:nil];
        }
        else
        {
            storyboard = [UIStoryboard storyboardWithName:@"Login-Universal" bundle:nil];
        }
        [self registerForNotifications];
    }
    
    if (controller)
    {
        //TODO: UGH! I HATE THIS SO MUCH! WHY WON'T YOU JUST WORK ALREADY?!
        NSLog(@"Opened from notification");
        RootViewController *initialViewController = [storyboard instantiateInitialViewController];
        NavigationViewController *navigation = [storyboard instantiateViewControllerWithIdentifier:@"contentController"];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = initialViewController;
        [self.window makeKeyAndVisible];
        [navigation presentViewControllerWithName:controller];
        
    }
    else
    {
        NSLog(@"Opened without notification");
        UIViewController *initialViewController = [storyboard instantiateInitialViewController];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController  = initialViewController;
        [self.window makeKeyAndVisible];
    }
}

@end
