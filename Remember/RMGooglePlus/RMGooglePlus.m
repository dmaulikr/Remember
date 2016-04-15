//
//  RMGooglePlus.m
//  Remember
//
//  Created by Keeton on 5/8/15.
//  Copyright (c) 2015 Solar Pepper Studios. All rights reserved.
//

#import "RMGooglePlus.h"

@interface RMGooglePlus ()
<GIDSignInDelegate, GIDSignInUIDelegate>
@property (strong, nonatomic) GIDSignIn *signIn;
@property (copy, nonatomic) UIImage *image;

@end

@implementation RMGooglePlus

- (id)init {
    if (self) {
        return self;
    } else {
        [super self];
        _image = [UIImage new];
        return self;
    }
}

- (void)signInAndRefreshInterface; {
    _signIn = [GIDSignIn sharedInstance];
    _signIn.shouldFetchBasicProfile = YES;
    _signIn.allowsSignInWithWebView = YES;
    _signIn.clientID = @"262401164415-hqcftmico35rqpotenujfcbbrgl4uej6.apps.googleusercontent.com";
    _signIn.scopes = @[@"profile"];
    _signIn.delegate = self;
    _signIn.uiDelegate = self;
    if ([_signIn hasAuthInKeychain])
    {
        [_signIn signInSilently];
    }
    else
    {
        [_signIn signIn];
    }
    
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if ([[GIDSignIn sharedInstance] hasAuthInKeychain])
    {
        //NSString *userId = user.userID;                  // For client-side use only!
        //NSString *idToken = user.authentication.idToken; // Safe to send to the server
        //NSString *email = user.profile.email;
        GIDProfileData *profileData = user.profile;
        _image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[profileData imageURLWithDimension:250]]];
        [self finishAndUpdate];
    }
    else
    {
        NSLog(@"Not authorized!");
    }
}

- (void)finishAndUpdate;
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"MainPhoto"]];
    
    NSString *photoPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imageName = [photoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"MainPhoto.jpg"]];
    NSData *imageData = UIImageJPEGRepresentation(_image, 1.0);
    [imageData writeToFile:imageName atomically:YES];
    
    // TODO: complete implementation
    //photoPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //imageName = [photoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"MainPhoto.jpg"]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"contactPhoto"];
}

@end
