//
//  RMNoteManager.m
//  Remember
//
//  Created by Keeton on 6/14/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import "RMNoteManager.h"

@interface RMNoteManager ()
@property (strong, nonatomic) NSString *groupID;
@end

@implementation RMNoteManager

- (id)initWithGroupID:(NSString *)group; {
    self = [super init];
    if (self) {
        _groupID = group;
    }
    return self;
}

- (void)writeNote:(RMNote *)note toURL:(NSURL *)url; {
    RMDataManager *dataManager = [[RMDataManager alloc] init];
    NSNumber *longitude = [note.noteLocationDictionary valueForKey:@"lon"];
    NSNumber *latitude = [note.noteLocationDictionary valueForKey:@"lat"];
    switch (note.getNoteVersion.integerValue) {
        case 0:
            [NSException raise:@"Invalid note version"
                        format:@"Note version does not exist: %li", (long)note.getNoteVersion.integerValue];
            break;
        case 1:
            [dataManager writeDataContentsWithTitle:note.noteTitle
                                             author:note.noteAuthor
                                               body:note.noteUnattributed];
            [dataManager writeCoordinatesWithLatitude:latitude.doubleValue
                                            longitude:longitude.doubleValue];
            break;
        case 2:
            //
            break;
        default:
            /**
             RMNote's documentation / comment on
             getNoteVersion returning value 0.
             */
            break;
    }
}

- (RMNote *)readNoteFromURL:(NSURL *)url; {
    return nil;
}

- (void)managerShouldUseContainerWithName:(NSString *)name; {
    
}

@end
