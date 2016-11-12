//
//  NotesTableCell.m
//  Remember
//
//  Created by Keeton on 10/14/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import "NotesTableCell.h"
#import "DetailViewController.h"

@implementation NotesTableCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (self.selected) {
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.duration = 0.1;
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.5, 1.5)];
        [self.customBackground pop_addAnimation:scaleAnimation forKey:@"scalingUp"];
        
        
        
    } else {
        POPBasicAnimation *scaleDown = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleDown.duration = 0.1;
        scaleDown.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        [self.customBackground pop_addAnimation:scaleDown forKey:@"scaleDown"];
    }

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (self.highlighted) {
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.duration = 0.1;
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.5, 1.5)];
        [self.customBackground pop_addAnimation:scaleAnimation forKey:@"scalingUp"];
        
        
        
    } else {
        POPSpringAnimation *sprintAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        sprintAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        sprintAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
        sprintAnimation.springBounciness = 8.f;
        [self.customBackground pop_addAnimation:sprintAnimation forKey:@"springAnimation"];
    }
}

@end
