//
//  NotesTableCell.h
//  Remember
//
//  Created by Keeton on 10/14/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface NotesTableCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *reminder;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UIImageView *customBackground;

@end
