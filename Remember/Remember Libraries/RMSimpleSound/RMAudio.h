//
//  SimpleSoundStatic.h
//  SimpleSoundStatic
//
//  Created by Keeton on 11/18/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface RMAudio : NSObject
<AVAudioPlayerDelegate>

/**
 Plays a custom sound with the desired name and file extension:
 playSoundWithName:(NSString *)name: The file name of the audio file.
 extention:(NSString *)extension:    The extension of the audio file.
 */

- (void)playSoundWithName:(NSString *)name extension:(NSString *)extension;

/**
 Plays a custom sound with the desired name and file extension and vibrates the phone:
 playSoundWithName:(NSString *)name: The file name of the audio file.
 extention:(NSString *)extension:    The extension of the audio file.
 */

- (void)playAlertWithName:(NSString *)name extension:(NSString *)extension;

/**
 Vibrates the phone only once. Provides no extra variables.
 Dude, you can't make this any simpler. Do I really need to
 document this action?
 */

- (void)startSystemVibration;

- (void)playMP3WithName:(NSString *)name;

@end
