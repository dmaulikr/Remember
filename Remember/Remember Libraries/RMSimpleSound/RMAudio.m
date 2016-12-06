//
//  SimpleSoundStatic.m
//  SimpleSoundStatic
//
//  Created by Keeton on 11/18/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import "RMAudio.h"

@implementation RMAudio

- (void)playSoundWithName:(NSString *)name extension:(NSString *)extension {
    // Plays a custom sound with the desired name and file extension
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:name ofType:extension];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Audio"] == TRUE)
    {
        AudioServicesPlaySystemSound (soundID);
    }
}

- (void)playAlertWithName:(NSString *)name extension:(NSString *)extension {
    // Plays a custom sound with the desired name and file extension
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:name ofType:extension];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Audio"] == TRUE)
    {
        AudioServicesPlayAlertSound (soundID);
    }
}

- (void)playMP3WithName:(NSString *)name; {
    AVAudioPlayer *audioPlayer;
    NSURL *path = [[NSBundle mainBundle] URLForResource:name withExtension:@"mp3"];
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:path error:nil];
    [audioPlayer setDelegate:self];
    [audioPlayer prepareToPlay];
    [audioPlayer play];
    [audioPlayer setVolume:1.0];
}

- (void)startSystemVibration {
    // Vibrates the phone only once. Provides no extra variables.
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

@end
