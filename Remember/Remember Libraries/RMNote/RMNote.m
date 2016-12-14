//
//  RMNote.m
//  Remember 2
//
//  Created by Keeton Feavel on 12/4/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import "RMNote.h"

@interface RMNote()
<NSCoding>

@end

@implementation RMNote

- (id)initWithCoder:(NSCoder *)coder; {
    if (self = [super init])
    {
        [self setName:[coder decodeObjectForKey:@"name"]];
        [self setBody:[coder decodeObjectForKey:@"body"]];
        [self setAuthor:[coder decodeObjectForKey:@"author"]];
        [self setImage:[coder decodeObjectForKey:@"image"]];
        [self setUrl:[coder decodeObjectForKey:@"url"]];
        [self setFire:[coder decodeObjectForKey:@"fire"]];
        [self setLocation:[coder decodeObjectForKey:@"location"]];
        [self setArray:[coder decodeObjectForKey:@"array"]];
    }
    return self;
}
 
- (void)encodeWithCoder:(NSCoder *)coder; {
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
