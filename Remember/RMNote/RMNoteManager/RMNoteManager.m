//
//  RMNoteManager.m
//  Remember
//
//  Created by Keeton on 6/14/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import "RMNoteManager.h"

@interface RMNoteManager ()
@property (strong, nonatomic) NSFileManager *fileManager;
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

- (void)writeNote:(RMNote *)note {
    RMDataManager *dataManager = [[RMDataManager alloc] init];
    NSNumber *longitude = [note.noteLocationDictionary valueForKey:@"lon"];
    NSNumber *latitude = [note.noteLocationDictionary valueForKey:@"lat"];
    switch (note.getNoteVersion.integerValue) {
        case -1:
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
            [NSException raise:@"Unknown note versioning issue"
                        format:@"Note version does not exist: %li", (long)note.getNoteVersion.integerValue];
            break;
    }
}

- (RMNote *)readNoteWithName:(NSString *)name; {
    NSMutableDictionary *data;
    _fileManager = [NSFileManager defaultManager];
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           _groupID];
    NSURL *path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",name]];
    
    if (![_fileManager fileExistsAtPath:[path path]])
    {
        path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",name]];
        //NSLog(@"Creating file...");
    }
    
    if ([_fileManager fileExistsAtPath:[path path]])
    {
        data = [[NSMutableDictionary alloc] initWithContentsOfFile:[path path]];
    } else {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
    }
    RMNote *note = [[RMNote alloc] initWithDictionary:data];
    return note;
}

- (NSString *)getManagerContainerName; {
    return _groupID;
}

@end
