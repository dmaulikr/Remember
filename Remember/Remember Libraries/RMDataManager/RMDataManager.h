//
//  RMDataManager.h
//  RMDataManager
//
//  Created by Keeton on 11/14/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface RMDataManager : NSObject
<CLLocationManagerDelegate>
@property (copy, nonatomic) NSString *rememberTitle;
/**
 Initialize RMDataManager with a custom group container identifier.
 */
- (id)initWithContainer:(NSString *)container;
/**
 Move all files from one directory to a new directory.
 */
//- (void)moveFilesFromDirectory:(NSString *)old toDirectory:(NSString *)new;

/**
 Allows the saving of NSMutableArrays and NSDictionaries into an appropriate plist file for data storage.
 
 Writes the contents of an NSDictionary to a plist file.
 (NSString *)rememberTitle: The title of your dictionary.
 (NSString *)author: The author of your dictionary.
 (NSString *)body: The main text of your dictionary.
 (NSString *)photoPath: This method is depreciated and should not be used.
 (double   *)latitude: Provides a double for MKMapView coordinates (latitude)
 (double   *)longitude: Provides a double for MKMapView coordinates (longitude)
 */
- (void)writeDataContentsWithTitle:(NSString *)rememberTitle author:(NSString *)author body:(NSString *)body;

/*
 Reads the contents of a plist into an NSDictionary. This library was designed as a method of saving notes
 (NSString *)rememberTitle: The title of your dictionary.
 (NSString *)author: The author of your dictionary.
 (NSString *)body: The main text of your dictionary.
 (NSString *)photoPath: This method is depreciated and should not be used.
 (UIImageView *)imageView: Allows the loading of a saved image into an imageView
 (double   *)latitude: Provides a double for MKMapView coordinates (latitude)
 (double   *)longitude: Provides a double for MKMapView coordinates (longitude)
 (MKMapView *)mapView: Allows the loading of latitude and longitude into an MKMapView
 */
- (void)readDataContentsWithTitle:(NSString *)rememberTitle containerID:(NSString *)containerID;
@property (copy, nonatomic) NSString *loadedAuthor;
@property (copy, nonatomic) NSString *loadedBody;
@property (copy, nonatomic) NSString *loadedPhotoPath;
@property double loadedLatitude;
@property double loadedLongitude;
/*
 
 */
- (void)deleteDataContentsWithTitle:(NSString*)title container:(NSString *)containerName;

/*
 Writes an NSMutableArray into a plist file in order to save the contents of a UITableView
 (NSMutableArray *)titles: The NSMutableArray that contains the contents of a UITableView's data
 */
- (void)writeTableContentsFromArray:(NSMutableArray *)titles containerID:(NSString *)containerID fileName:(NSString*)fileName;

/*
 Reads the contents of a plist into an NSMutableArray in order to load the contents of a UITableView
 (NSMutableArray *)titles: The NSMutableArray that will contain the contents of the plist's data
 */
- (void)readTableContentsFromContainerID:(NSString *)containerID fileName:(NSString*)fileName;
@property (copy, nonatomic) NSMutableArray *loadedTitles;

/*
 Adds a string to the table array and then writes it into the plist file using - (void)writeTableContentsFromArray:(NSMutableArray *)titles
 */
- (void)addContentsToTable:(NSString *)title containerID:(NSString *)containerID fileName:(NSString*)fileName;

/*
 Coordinate stuff
 */
- (void)writeCoordinates;
- (void)writeCoordinatesWithLatitude:(double)latitude longitude:(double)longitude;
- (void)readCoordinates;

/*
 Date stuff
 */
- (void)writeDates:(NSDate *)date title:(NSString *)rememberTitle;
- (void)readDates:(NSString *)rememberTitle;
@property (copy, nonatomic) NSString *loadedDateName;

/*
 Writes a URL for a note to a plist file.
 (NSURL *)url: The URL associated with the note.
 (NSString *)rememberTitle: The note title to which the URL is written.
 */
- (void)writeURL:(NSURL *)url title:(NSString *)rememberTitle;
/*
 Returns a URL for a note from a plist file given a note title.
 (NSURL *)url: The URL associated with the note.
 (NSString *)rememberTitle: The note title from which the URL is loaded.
 */
- (NSURL *)readURL:(NSString *)rememberTitle;

- (void)deleteFileWithName:(NSString*)title container:(NSString *)containerName;

@end
