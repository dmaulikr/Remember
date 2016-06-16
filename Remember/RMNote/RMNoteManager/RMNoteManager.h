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
- (void)writeNote:(RMNote *)note toURL:(NSURL *)url;
- (RMNote *)readNoteFromURL:(NSURL *)url;
- (void)managerShouldUseContainerWithName:(NSString *)name;

@end
