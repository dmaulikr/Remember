//
//  RMNote.m
//  Remember 2
//
//  Created by Keeton Feavel on 12/4/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import "RMNote.h"

@interface RMNote()

@end

@implementation RMNote

- (id)init; {
    self = [super init];
    if (self) {
        // Custom initilization
        _name = @"Error Name";
        _body = [[NSAttributedString alloc] initWithString:@"" attributes:nil];
        _author = @"";
        _image = [UIImage new];
        _url = [[NSURL alloc] initWithString:@""];
        _fire = [NSDate new];
        _location = [NSArray new];
        _array = [NSMutableArray new];
    }
    return self;
}


- (id)initWithName:(NSString *)name; {
    self = [super init];
    if (self) {
        // Custom initilization
        _name = name;
        _body = [[NSAttributedString alloc] initWithString:@"" attributes:nil];
        _author = @"";
        _image = [UIImage new];
        _url = [[NSURL alloc] initWithString:@""];
        _fire = [NSDate new];
        _location = [NSArray new];
        _array = [NSMutableArray new];
    }
    return self;
}

- (void)debugNoteContents {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"RMDebug"]) {
        NSLog(@"-- RMNote Debugging --");
        NSLog(@"Name: %@",_name);
        NSLog(@"Body: %@",_body);
        NSLog(@"Author: %@",_author);
        NSLog(@"URL: %@",_url);
        NSLog(@"Fire: %@",_fire);
        NSLog(@"Location: %@",_location);
        NSLog(@"Array: %@",_array);
        NSLog(@"-- End RMNote Data  --");
    }
}

@end
