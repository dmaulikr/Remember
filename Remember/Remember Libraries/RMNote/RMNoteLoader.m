//
//  RMNoteLoader.m
//  Remember 2
//
//  Created by Keeton Feavel on 12/6/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import "RMNoteLoader.h"

@interface RMNoteLoader ()

@property NSMutableDictionary *data;

@end

@implementation RMNoteLoader

- (id)init //WithNote:(RMNote *)note
{
    if (self = [super init])
    {
        /*
        NSArray * keys      = [NSArray arrayWithObjects: @"author", @"body", @"url", @"note", @"image", @"location", @"date", nil];
        NSArray * values    = [NSArray arrayWithObjects: note.author, note.body, note.url, note.image, note.location, note.fire, nil];
        _data               = [[NSMutableDictionary alloc] initWithObjects:values forKeys:keys];
        */
    }
    return self;
}
/*
- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init])
    {
        [self setData: [coder decodeObjectForKey:@"data"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_data forKey:@"data"];
}
*/
- (NSString *)pathForDataFileWithName:(NSString *)name
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *container = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    NSURL *folder = [container URLByAppendingPathComponent:name];

    NSError *error;
    if ([fileManager fileExistsAtPath:[folder path]] == NO)
    {
        [fileManager createDirectoryAtURL:[NSURL URLWithString:[folder path]] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    NSString *fileName = [NSString stringWithFormat:@"data.rmb"];
    return [[folder path] stringByAppendingPathComponent: fileName];
}

- (void)saveDataToDiskWithNote:(RMNote *)note
{
    NSString *path = [self pathForDataFileWithName:note.name];
    
    NSMutableDictionary *rootObject;
    rootObject = [NSMutableDictionary dictionary];
    
    [rootObject setValue:note forKey:@"data"];
    [NSKeyedArchiver archiveRootObject:rootObject toFile:path];
    NSLog(@"Saved data to disk: %@", path);
}

- (RMNote *)loadDataFromDiskWithName:(NSString *)name
{
    RMNote *note;
    NSString *path = [self pathForDataFileWithName:name];
    NSDictionary *rootObject;
    
    rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    note = [rootObject valueForKey:@"data"];
    NSLog(@"Loaded data from path: %@", path);
    
    return note;
}

@end
