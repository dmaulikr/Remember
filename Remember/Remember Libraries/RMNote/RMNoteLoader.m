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
        NSLog(@"RMNoteLoader initialiazed.");
    }
    return self;
}

- (NSString *)pathForDataFileWithName:(NSString *)name;
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *container = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    NSURL *folder = [container URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",name]];
    NSLog(@"Folder: %@",folder);
    NSError *error;
    if ([fileManager fileExistsAtPath:[folder path]] == NO)
    {
        NSLog(@"Creating directory.");
        if ([fileManager createDirectoryAtURL:[NSURL fileURLWithPath:[folder path]] withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Created successfully.");
        } else {
            NSLog(@"Failed to create directory. \n %@",error);
        }
    }
    
    NSString *fileName = [NSString stringWithFormat:@"data.rmb"];
    NSString *result = [[folder path] stringByAppendingPathComponent: fileName];
    
    return result;
}

- (void)saveDataToDiskWithNote:(RMNote *)note andName:(NSString *)name;
{
    [note debugNoteContents];
    NSMutableData *data = [NSMutableData data];
    //RMNote *allocated = [[RMNote alloc] initWithName:name];
    
    //Create a NSKeyedArchiver instance to write that will write the User insance to the data instance.
    //Call encodeWithCoder: on the user instance
    //Call finishEncoding on the archiver instance. The archiver instance will not write the data until finishEncoding is called.
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [note encodeWithCoder:archiver];
    [archiver finishEncoding];
    //Create a path to file in the documents directory where you want the data to be saved
    //Write the data to the file using writeToFile:atomically:
    NSError *error;
    NSLog(@"Preparing to write to path: %@", [self pathForDataFileWithName:name]);
    if ([data writeToFile:[self pathForDataFileWithName:name] options:NSDataWritingAtomic error:&error]) {
        NSLog(@"Wrote successfully.");
    } else {
        NSLog(@"%@",error);
    }
}

- (RMNote *)loadDataFromDiskWithName:(NSString *)name;
{
    //If name is not nil, then set it to the mUserName instance variable so it can be saved. Then return.
    RMNote *note;
    //Find the path to the file that contains the data of a saved User object.
    NSLog(@"Looking for file at path:   %@", [self pathForDataFileWithName:name]);
    //Check and see if the file exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self pathForDataFileWithName:name]])
    {
        NSLog(@"RMNoteLoader: File does exist. Initializing with coder: %@",[self pathForDataFileWithName:name]);
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:[self pathForDataFileWithName:name]]];
        note = [[RMNote alloc] initWithCoder:unarchiver];
        [unarchiver finishDecoding];
    } else {
        NSLog(@"RMNoteLoader: File doesn't exist. Initializing blank note. Calling initWithName:%@",name);
        note = [[RMNote alloc] initWithName:name];
    }
    NSLog(@"RMNote Initialized with name: %@",name);
    
    return note;
}

@end
