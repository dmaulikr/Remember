//
//  NanoCell.h
//  Remember
//
//  Created by Keeton on 4/12/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface NanoCell : NSObject
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *cellDisplayName;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *cellDisplayAuthor;

@end
