//
//  RMNoteManager.h
//  Remember
//
//  Created by Keeton on 6/14/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMNote.h"
#import "RMDataManager.h"

@interface RMNoteManager : NSObject

- (id)initWithGroupID:(NSString *)groupID;
- (NSString *)getManagerContainerName;
- (void)writeNote:(RMNote *)note;
- (RMNote *)readNoteWithName:(NSString *)name;

@end
