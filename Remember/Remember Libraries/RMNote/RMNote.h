//
//  RMNote.h
//  Remember 2
//
//  Created by Keeton Feavel on 12/4/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMNote : NSObject

@property (weak, nonatomic) NSString *note;
@property (weak, nonatomic) NSString *author;
@property (weak, nonatomic) UIImage *image;
@property (weak, nonatomic) NSURL *url;
@property (weak, nonatomic) NSDate *fire;

@end
