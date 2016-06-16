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

- (id)initWithDictionary:(NSDictionary *)dict; {
    self = [super init];
    if (self) {
        _data.dictionary = dict;
    }
    return self;
}

- (void)processNoteDictionary:(NSDictionary *)dict; {
    //RMDataManager *dataManager = [[RMDataManager alloc] initWithContainer:[RMNoteManager getManagerContainerName]];
    switch ([self getNoteVersion].integerValue) {
        case 1:
            self.noteUnattributed = [dict valueForKey:@"note"];
            break;
        case 2:
            //
            break;
        default:
            break;
    }
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
            return [NSNumber numberWithInt:-1];
            break;
    }
}

@end
