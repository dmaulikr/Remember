//
//  AppDelegate.h
//  Remember
//
//  Created by Keeton on 10/11/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//
//  Remember, a proud supporter of the Objective-C language.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleSignIn/GoogleSignIn.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSString *kClientId;

- (void)initializeStoryBoardBasedOnScreenSize:(NSString *)controller;

@end

