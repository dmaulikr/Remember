//
//  RMNote.m
//  Remember 2
//
//  Created by Keeton Feavel on 12/4/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import "RMNote.h"

@interface RMNote()

@property (strong, nonatomic) NSKeyedUnarchiver *archiver;

@end

@implementation RMNote

- (id)initWithName:(NSString *)name; {
    self = [super init];
    if (self) {
        //If name is not nil, then set it to the mUserName instance variable so it can be saved. Then return.
        if (_name) {
            //_name = name;
            NSLog(@"RMNote: Name != nil: %@",_name);
        }
        //If name is nil look for a saved instance of the User object and return it or set the mUserName variable to "Default User".
        else {
            //Find the path to the file that contains the data of a saved User object.
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *container = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                                @"group.com.solarpepper.Remember"];
            NSURL *folder = [container URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",name]];
            NSString *fileName = [NSString stringWithFormat:@"data.rmb"];
            NSString *result = [[folder path] stringByAppendingPathComponent: fileName];
            NSLog(@"RMNote: Looking for file at path: %@",result);
            //Check and see if the file exists
            if ([fileManager fileExistsAtPath:result]) {
                NSLog(@"RMNote: File does exist. Initializing with coder");
                _archiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:result]];
                self = [[RMNote alloc] initWithCoder:_archiver];
                [_archiver finishDecoding];
                NSLog(@"RMNote: Finished decoding.");
            } else {
                _name = name;
                NSLog(@"RMNote: File does not exist: %@. Allocating new object",_name);
                /*
                [self setBody:[_nsc decodeObjectForKey:@"body"]];
                [self setAuthor:[_nsc decodeObjectForKey:@"author"]];
                [self setImage:[_nsc decodeObjectForKey:@"image"]];
                [self setUrl:[_nsc decodeObjectForKey:@"url"]];
                [self setFire:[_nsc decodeObjectForKey:@"fire"]];
                [self setLocation:[_nsc decodeObjectForKey:@"location"]];
                [self setArray:[_nsc decodeObjectForKey:@"array"]];
                */
                [self setBody:[[NSAttributedString alloc] initWithString:@"" attributes:nil]];
                [self setAuthor:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"RMAuthor"]]];
                [self setImage:[[UIImage alloc] init]];
                [self setUrl:[[NSURL alloc] initWithString:@""]];
                [self setFire:[[NSDate alloc] init]];
                [self setLocation:@[]];
                [self setArray:[[NSMutableArray alloc] init]];
            }
        }
    }
    NSLog(@"RMNote Initialized with name: %@",_name);
    return self;
}

- (id)initWithCoder:(NSCoder *)coder; {
    NSLog(@"RMNote: initWithCoder...");
    _name = [_archiver decodeObjectForKey:@"name"];
    _body = [_archiver decodeObjectForKey:@"body"];
    _author = [_archiver decodeObjectForKey:@"author"];
    _image = [_archiver decodeObjectForKey:@"image"];
    _url = [_archiver decodeObjectForKey:@"url"];
    _fire = [_archiver decodeObjectForKey:@"fire"];
    _location = [_archiver decodeObjectForKey:@"location"];
    _array = [_archiver decodeObjectForKey:@"array"];
    return self;
}
 
- (void)encodeWithCoder:(NSCoder *)coder; {
    NSLog(@"RMNote: encodeWithCoder...");
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_body forKey:@"body"];
    [coder encodeObject:_author forKey:@"author"];
    [coder encodeObject:_image forKey:@"image"];
    [coder encodeObject:_url forKey:@"url"];
    [coder encodeObject:_fire forKey:@"fire"];
    [coder encodeObject:_location forKey:@"location"];
    [coder encodeObject:_array forKey:@"array"];
}

- (void)debugNoteContents; {
    //if ([[NSUserDefaults standardUserDefaults] boolForKey:@"RMDebug"]) {
        NSLog(@"-- RMNote Debugging --");
        NSLog(@"Name: %@",_name);
        NSLog(@"Body: %@",_body);
        NSLog(@"Author: %@",_author);
        NSLog(@"URL: %@",_url);
        NSLog(@"Fire: %@",_fire);
        NSLog(@"Location: %@",_location);
        NSLog(@"Array: %@",_array);
        NSLog(@"-- End RMNote Data  --");
    //}
}

@end
