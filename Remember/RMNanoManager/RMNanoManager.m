//
//  RMNanoManager.m
//  Remember
//
//  Created by Keeton on 4/12/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import "RMNanoManager.h"

@interface RMNanoManager ()
@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSMutableArray *nanoTitles;

@end

@implementation RMNanoManager

- (void)readTableContentsFromContainerID:(NSString *)containerID fileName:(NSString*)fileName {
    /**
     Loads the contents of a plist into a tableView array.
     */
    
    NSMutableDictionary *data;
    _fileManager = [NSFileManager defaultManager];
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    
    NSURL *path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.remember",fileName]];
    //NSLog(@"Path write: %@",path);
    
    if (![_fileManager fileExistsAtPath:[path path]])
    {
        path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.remember",fileName]];
        //NSLog(@"Creating file...");
    } else {
        //NSLog(@"File exists at path!");
    }
    
    if ([_fileManager fileExistsAtPath:[path path]])
    {
        data = [[NSMutableDictionary alloc] initWithContentsOfURL:path];
    } else {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
    }
    
    _nanoTitles = [[NSMutableArray alloc] initWithArray:[data objectForKey:@"Titles"]];
}

- (void)readDataContentsWithTitle:(NSString *)rememberTitle containerID:(NSString *)containerID {
    /**
     Loads the plist path and load NSDictionary objects into memory. Places the appropriate objects into their holders.
     */
    NSMutableDictionary *data;
    _fileManager = [NSFileManager defaultManager];
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    
    NSURL *path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.remember",rememberTitle]];
    //NSLog(@"Path read: %@",path);
    
    if (![_fileManager fileExistsAtPath:[path path]]) {
        path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.remember",rememberTitle]];
        //NSLog(@"Creating file...");
    } else {
        //NSLog(@"File exists at path!");
    }
    
    if ([_fileManager fileExistsAtPath:[path path]]) {
        data = [[NSMutableDictionary alloc] initWithContentsOfURL:path];
    } else {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
    }
    
    _nanoAuthor = [data objectForKey:[NSString stringWithFormat:@"%@+Author",rememberTitle]];
    _nanoBody = [data objectForKey:[NSString stringWithFormat:@"%@+Note",rememberTitle]];
    _nanoPhotoPath = [[containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/"]] path];
    
    NSString *imageName = [_nanoPhotoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",rememberTitle]];
    if (![_fileManager fileExistsAtPath:imageName]) {
        //_nanoImage.image = [WKImage imageNamed:@"Camera Thumb"];
        //imageView.contentMode = UIViewContentModeCenter;
    } else {
        //imageView.image = [UIImage imageWithContentsOfFile:imageName];
        //imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

@end
