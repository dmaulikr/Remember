//
//  RMNote.m
//  Remember
//
//  Created by Keeton on 6/14/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import "RMNote.h"

@interface RMNote ()
@property (strong, nonatomic) NSMutableDictionary *data;
@end

@implementation RMNote

- (id)init; {
    self = [super init];
    if (self) {
        // Custom initilization
    }
    return self;
}

- (NSNumber *)getNoteVersion; {
    NSNumber *version = [_data objectForKey:@"version"];
    switch (version.integerValue) {
        case 1:
            return [NSNumber numberWithInt:1];
            break;
        case 2:
            return [NSNumber numberWithInt:2];
            break;
        default:
            /**
             In the event that a note is created with an invalid
             version value, RMNote (or RMNoteManager) should go
             ahead at attempting to load the note. In most cases
             the notes will be compatible past version 2.0 assuming
             I do things right this time around instead of saving
             everything to plist files and ignoring NSData.
             */
            return [NSNumber numberWithInt:0];
            break;
    }
}

@end
