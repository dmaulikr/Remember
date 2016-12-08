//
//  RMNoteLoader.h
//  Remember 2
//
//  Created by Keeton Feavel on 12/6/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMNote.h"

@interface RMNoteLoader : NSObject

- (id)init;
- (NSString *)pathForDataFileWithName:(NSString *)name;
- (void)saveDataToDiskWithNote:(RMNote *)note;
- (RMNote *)loadDataFromDiskWithName:(NSString *)name;

@end
