//
//  MKAlertView.h
//  Remember
//
//  Created by Keeton on 10/31/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKAlertView : UIAlertView
<MKMapViewDelegate>
{
    MKMapView *map;
}

@property (strong, nonatomic) MKMapView *map;
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle latitude:(CLLocationDegrees *)latitude longitude:(CLLocationDegrees *)longitude;

@end
