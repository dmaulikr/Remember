//
//  MapViewController.m
//  Remember
//
//  Created by Keeton on 11/4/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import "MapViewController.h"
#import "DetailViewController.h"
#import "RMView.h"

@interface MapViewController ()
<CLLocationManagerDelegate>
/*-------------------------------------------------------*/
@property (weak, nullable) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) MKUserLocation *location;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (copy, nonnull) RMAudio *sound;
@property (copy, nonnull) RMDataManager *data;
@property double latitude;
@property double longitude;
/*-------------------------------------------------------*/

@end

@implementation MapViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _data = [RMDataManager new];
    RMView *corners = [RMView new];
    [corners createViewWithRoundedCornersWithRadius:20.0 andView:_mapView];
    [corners createViewWithRoundedCornersWithRadius:20.0 andView:_dismissButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_data readDataContentsWithTitle:self.rememberTitle
                           containerID:@"group.com.solarpepper.Remember"];
    [self updateMapView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    _mapView = nil;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    //[self dismissViewSound];
}

# pragma mark - MapKit Management

- (void)updateMapView
{
    [_data readCoordinates];
    
    // Needed?
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
    
    _latitude = _data.loadedLatitude;
    _longitude = _data.loadedLongitude;
    
    CLLocationCoordinate2D coord = {.latitude = _latitude, .longitude = _longitude};
    MKCoordinateSpan span = {.latitudeDelta =  1, .longitudeDelta =  1};
    MKCoordinateRegion region = {coord, span};
    [_mapView setRegion:region];
    _mapView.showsUserLocation = NO;
    
    // Maybe comment because we really don't need a point on the small map?
    MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
    ann.title = @"Note Location";
    ann.coordinate = region.center;
    [_mapView addAnnotation:ann];
    
}

#pragma mark - Audio Management

- (void)dismissViewSound
{
    _sound = [[RMAudio alloc] init];
    [_sound playSoundWithName:@"1" extension:@"caf"];
}

@end
