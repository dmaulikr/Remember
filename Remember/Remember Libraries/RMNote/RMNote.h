//
//  RMNote.h
//  Remember 2
//
//  Created by Keeton Feavel on 12/4/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RMNote : NSObject

- (id)init;
- (id)initWithName:(NSString *)name;
- (void)debugNoteContents;

@property (strong, nonatomic) NSString              *name;
@property (strong, nonatomic) NSAttributedString    *body;
@property (strong, nonatomic) NSString              *author;
@property (strong, nonatomic) UIImage               *image;
@property (strong, nonatomic) NSURL                 *url;
@property (strong, nonatomic) NSDate                *fire;
@property (strong, nonatomic) NSArray               *location;
@property (strong, nonatomic) NSMutableArray        *array;

@end
