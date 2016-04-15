//
//  MKAlertView.m
//  Remember
//
//  Created by Keeton on 10/31/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import "MKAlertView.h"
#import "RMView.H"

@implementation MKAlertView
@synthesize map;

#define METERS_PER_MILE 1609.344

- (void) drawRect:(CGRect)rect
{
    map = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, 10.0, self.frame.size.height, self.frame.size.width)];
    [map setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:map];
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 130.0);
    [self setTransform:translate];
    RMView *corners = [RMView new];
    [corners createViewWithRoundedCornersWithRadius:10.0 andView:map];
}

- (void) show {
    // call the super show method to initiate the animation
    [super show];
    
    // resize the alert view to fit the image
    CGSize mapSize = self.map.frame.size;
    self.bounds = CGRectMake(0, 0, mapSize.width, mapSize.height);
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle latitude:(CLLocationDegrees *)latitude longitude:(CLLocationDegrees *)longitude
{
    if (self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil, nil])
    {
        CLLocationCoordinate2D savedCoordinate;
        savedCoordinate.latitude = *latitude;
        savedCoordinate.longitude = *longitude;
        
        //create annotation object using savedCoordinate and add to map view...
        MKPointAnnotation *ann1 =[[MKPointAnnotation alloc] init];
        ann1.title=@"Location";
        ann1.subtitle=@"";
        ann1.coordinate= savedCoordinate;
        [map addAnnotation:ann1];
        
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(savedCoordinate, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
        [map setRegion:viewRegion animated:NO];

    }
    return self;
}

@end
