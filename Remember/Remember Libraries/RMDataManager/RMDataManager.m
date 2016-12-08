//
//  RMDataManager.m
//  RMDataManager
//
//  Created by Keeton on 11/14/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import "RMDataManager.h"

@interface RMDataManager ()
//<DBRestClientDelegate>

//@property (nonatomic, strong) DBRestClient *restClient;
@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSURL *containerURL;

@end

@implementation RMDataManager
@synthesize loadedAuthor;
@synthesize loadedBody;
@synthesize loadedPhotoPath;
@synthesize loadedLatitude;
@synthesize loadedLongitude;
@synthesize loadedTitles;
@synthesize loadedDateName;

# pragma mark - Data Management

- (id)init; {
    self = [super init];
    if (self) {
        // Custom initilization
        //TODO: Update init to initWithContainer and reword everything to leave less of a memory impact
        _fileManager = [NSFileManager new];
        _containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                         @"group.com.solarpepper.Remember"];
    }
    return self;
}

- (id)initWithContainer:(NSString *)container; {
    self = [super init];
    if (self) {
        // Custom initilization
        //TODO: Update init to initWithContainer and reword everything to leave less of a memory impact
        _fileManager = [NSFileManager new];
        _containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                         container];
    }
    return self;
}
/*
- (void)moveFilesFromDirectory:(NSString *)old toDirectory:(NSString *)new; {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError *error;
    NSArray *files = [fm contentsOfDirectoryAtPath:old error:&error];
    
    for (NSString *file in files) {
        [fm moveItemAtPath:[old stringByAppendingPathComponent:file]
                    toPath:[new stringByAppendingPathComponent:file]
                     error:&error];
    }
}

- (void)moveFilesFromDirectoryToDropbox:(NSString *)dir; {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError *error;
    NSArray *files = [fm contentsOfDirectoryAtPath:dir error:&error];
    
    for (NSString *file in files) {
        [self.restClient uploadFile:file toPath:@"/Remember" withParentRev:nil fromPath:dir];
    }
}

- (void)moveFilesFromDropboxToDirectory:(NSString *)dir; {
 
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError *error;
    NSArray *files = [fm contentsOfDirectoryAtPath:dir error:&error];
    
    for (NSString *file in files) {
        [self.restClient loadFile:[NSString stringWithFormat:@"/Remember/%@",file] intoPath:dir];
    }
 
}
*/
- (void)writeDataContentsWithTitle:(NSString *)rememberTitle author:(NSString *)author body:(NSString *)body {
    /**
     Write the NSDictionary into the plist and insert the objects into their appropriate identifiers.
     */
    
    NSMutableDictionary *data;
    _fileManager = [NSFileManager defaultManager];
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    
    NSURL *documents = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents"]];
    NSURL *path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.remember",rememberTitle]];
    //NSLog(@"Path write: %@",path);
    
    if (![_fileManager fileExistsAtPath:[path path]]) // watch out for the !
    {
        path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.remember",rememberTitle]];
        //NSLog(@"Creating file...");
    }
    
    if ([_fileManager fileExistsAtPath:[path path]])
    {
        data = [[NSMutableDictionary alloc] initWithContentsOfURL:path];
        //NSLog(@"File exists at path!");
    }
    else
    {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
    }
    
    /*
     Create Documents Directory in Shared Container
     */
    if ([_fileManager fileExistsAtPath:[documents path] isDirectory:nil])
    {
        //NSLog(@"Documents exists");
    }
    else
    {
        //NSLog(@"Documents create");
        [_fileManager createDirectoryAtURL:documents withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    /*
     Write data to .plist file disguised as .remember file
     */
    
    [data setObject:author
             forKey:[NSString stringWithFormat:@"%@+Author",rememberTitle]];
    [data setObject:body
             forKey:[NSString stringWithFormat:@"%@+Note",rememberTitle]];
    //TODO: Update everything from NSMutableDictionary to NSData along with NSFileManager
    [data setObject:[NSNumber numberWithBool:false] forKey:@"Updated"];
    [data writeToURL:path atomically:YES];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"RMDebug"]) {
        NSLog(@"File Attributes: %@",[[NSFileManager defaultManager] attributesOfItemAtPath:[path path]
                                                         error:NULL]);
    }
    self.rememberTitle = rememberTitle;
    [self writeCoordinates];
}

- (void)readDataContentsWithTitle:(NSString *)rememberTitle containerID:(NSString *)containerID {
    /**
     Loads the plist path and load NSDictionary objects into memory. Places the appropriate objects into their holders.
     */
    
    NSMutableDictionary *data;
    _fileManager = [NSFileManager defaultManager];
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    
    NSURL *path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.remember",rememberTitle]];
    //NSLog(@"Path read: %@",path);
    
    if (![_fileManager fileExistsAtPath:[path path]]) {
        path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.remember",rememberTitle]];
        //NSLog(@"Creating file...");
    } else {
        //NSLog(@"File exists at path!");
    }
    
    if ([_fileManager fileExistsAtPath:[path path]]) {
        data = [[NSMutableDictionary alloc] initWithContentsOfURL:path];
    } else {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
    }
    
    loadedAuthor = [data objectForKey:[NSString stringWithFormat:@"%@+Author",rememberTitle]];
    loadedBody = [data objectForKey:[NSString stringWithFormat:@"%@+Note",rememberTitle]];
    loadedPhotoPath = [[containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/"]] path];
    /*
    NSString *imageName = [loadedPhotoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",rememberTitle]];
    if (![_fileManager fileExistsAtPath:imageName]) {
        imageView.image = [UIImage imageNamed:@"Camera Thumb"];
        imageView.contentMode = UIViewContentModeCenter;
    } else {
        imageView.image = [UIImage imageWithContentsOfFile:imageName];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    */
    self.rememberTitle = rememberTitle;
    
    [self readCoordinates];
}

- (void)deleteDataContentsWithTitle:(NSString*)title container:(NSString *)containerName {
    _fileManager = [NSFileManager new];
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           containerName];
    /* Define file paths */
    NSURL *container = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.remember",title]];
    NSURL *imageName = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.jpg",title]];
    /* Delete Save Data Files */
    [_fileManager removeItemAtURL:container error:nil];
    [_fileManager removeItemAtURL:imageName error:nil];
}

- (void)deleteFileWithName:(NSString*)title container:(NSString *)containerName; {
    _fileManager = [[NSFileManager alloc] init];
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           containerName];
    NSURL *container = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",title]];
    /* Delete Files */
    [_fileManager removeItemAtURL:container error:nil];
}

# pragma mark - Table Data Management

- (void)writeTableContentsFromArray:(NSMutableArray *)titles containerID:(NSString *)containerID fileName:(NSString*)fileName {
    /**
     Writes the contents of a table view into a plist file for later data usage.
     */
    
    NSMutableDictionary *data;
    _fileManager = [NSFileManager defaultManager];
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    
    NSURL *path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.remember",fileName]];
    //NSLog(@"Path write: %@",path);
    
    if (![_fileManager fileExistsAtPath:[path path]]) //Watch out for the !
    {
        path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.remember",fileName]];
        //NSLog(@"Creating file...");
    } else {
        //NSLog(@"File exists at path!");
    }
    
    if ([_fileManager fileExistsAtPath:[path path]])
    {
        data = [[NSMutableDictionary alloc] initWithContentsOfURL:path];
    } else {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
    }
    [data setObject:titles forKey:@"Titles"];
    [data writeToURL:path atomically:YES];
}

- (void)readTableContentsFromContainerID:(NSString *)containerID fileName:(NSString*)fileName {
    /**
     Loads the contents of a plist into a tableView array.
     */
    
    NSMutableDictionary *data;
    _fileManager = [NSFileManager defaultManager];
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    
    NSURL *path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.remember",fileName]];
    //NSLog(@"Path write: %@",path);
    
    if (![_fileManager fileExistsAtPath:[path path]])
    {
        path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.remember",fileName]];
        //NSLog(@"Creating file...");
    } else {
        //NSLog(@"File exists at path!");
    }
    
    if ([_fileManager fileExistsAtPath:[path path]])
    {
        data = [[NSMutableDictionary alloc] initWithContentsOfURL:path];
    } else {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
    }
    
    loadedTitles = [[NSMutableArray alloc] initWithArray:[data objectForKey:@"Titles"]];
}

- (void)addContentsToTable:(NSString *)title containerID:(NSString *)containerID fileName:(NSString*)fileName {
    /**
     Writes the contents of a table view into a plist file for later data usage.
     */
    
    NSMutableDictionary *data;
    _fileManager = [NSFileManager defaultManager];
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    
    NSURL *path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.remember",fileName]];
    //NSLog(@"Path write: %@",path);
    
    if (![_fileManager fileExistsAtPath:[path path]])
    {
        path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.remember",fileName]];
        //NSLog(@"Creating file...");
    } else {
        //NSLog(@"File exists at path!");
    }
    
    if ([_fileManager fileExistsAtPath:[path path]])
    {
        data = [[NSMutableDictionary alloc] initWithContentsOfURL:path];
    } else {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
    }
    
    [self readTableContentsFromContainerID:containerID
                                  fileName:fileName];
    [loadedTitles addObject:title];
    [data setObject:self.loadedTitles forKey:@"Titles"];
    [data writeToURL:path atomically:YES];
}

#pragma mark - Coordinate Saving

- (void)writeCoordinates {
    /**
     Write the NSDictionary into the plist and insert the objects into their appropriate identifiers.
     */
    
    NSMutableDictionary *data;
    _fileManager = [NSFileManager defaultManager];
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    NSURL *path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Coordinates.remember"]];
    
    if (![_fileManager fileExistsAtPath:[path path]]) // watch out for the !
    {
        path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Coordinates.remember"]];
        //NSLog(@"Creating file...");
    }
    
    if ([_fileManager fileExistsAtPath:[path path]])
    {
        data = [[NSMutableDictionary alloc] initWithContentsOfURL:path];
        //NSLog(@"File exists at path!");
    } else {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
    }
    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager locationServicesEnabled])
    {
        if (!locationManager)
            locationManager = [[CLLocationManager alloc] init];
        
        locationManager.delegate = self;
        [locationManager startMonitoringSignificantLocationChanges];
    }
    
    [data setObject:[NSNumber numberWithDouble:locationManager.location.coordinate.latitude]
             forKey:[NSString stringWithFormat:@"%@+Latitude",self.rememberTitle]];
    [data setObject:[NSNumber numberWithDouble:locationManager.location.coordinate.longitude]
             forKey:[NSString stringWithFormat:@"%@+Longitude",self.rememberTitle]];
    [data writeToURL:path atomically:YES];
}

- (void)writeCoordinatesWithLatitude:(double)latitude longitude:(double)longitude {
    /**
     Write the NSDictionary into the plist and insert the objects into their appropriate identifiers.
     */
    
    NSMutableDictionary *data;
    _fileManager = [NSFileManager defaultManager];
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    NSURL *path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Coordinates.remember"]];
    
    if (![_fileManager fileExistsAtPath:[path path]]) // watch out for the !
    {
        path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Coordinates.remember"]];
        //NSLog(@"Creating file...");
    }
    
    if ([_fileManager fileExistsAtPath:[path path]])
    {
        data = [[NSMutableDictionary alloc] initWithContentsOfURL:path];
        //NSLog(@"File exists at path!");
    } else {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
    }
    
    [data setObject:[NSNumber numberWithDouble:latitude]
             forKey:[NSString stringWithFormat:@"%@+Latitude",self.rememberTitle]];
    [data setObject:[NSNumber numberWithDouble:longitude]
             forKey:[NSString stringWithFormat:@"%@+Longitude",self.rememberTitle]];
    [data writeToURL:path atomically:YES];
}


- (void)readCoordinates {
    NSMutableDictionary *data;
    _fileManager = [NSFileManager defaultManager];
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    NSURL *path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Coordinates.remember"]];
    
    if (![_fileManager fileExistsAtPath:[path path]]) // watch out for the !
    {
        path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Coordinates.remember"]];
        //NSLog(@"Creating file...");
    }
    
    if ([_fileManager fileExistsAtPath:[path path]])
    {
        data = [[NSMutableDictionary alloc] initWithContentsOfURL:path];
        //NSLog(@"File exists at path!");
    } else {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
    }
    NSNumber *latitudeNumber = [data objectForKey:[NSString stringWithFormat:@"%@+Latitude",self.rememberTitle]];
    NSNumber *longitudeNumber = [data objectForKey:[NSString stringWithFormat:@"%@+Longitude",self.rememberTitle]];
    
    loadedLatitude = [latitudeNumber doubleValue];
    loadedLongitude = [longitudeNumber doubleValue];
}

#pragma mark - Date Saving

- (void)writeDates:(NSDate *)date title:(NSString *)rememberTitle {
    /**
     Write the NSDictionary into the plist and insert the objects into their appropriate identifiers.
     */
    
    NSMutableDictionary *data;
    _fileManager = [NSFileManager defaultManager];
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    NSURL *path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Dates.remember"]];
    
    if (![_fileManager fileExistsAtPath:[path path]]) // watch out for the !
    {
        path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Dates.remember"]];
        //NSLog(@"Creating file...");
    }
    
    if ([_fileManager fileExistsAtPath:[path path]])
    {
        data = [[NSMutableDictionary alloc] initWithContentsOfURL:path];
        //NSLog(@"File exists at path!");
    } else {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
    }
    
    [data setObject:date
             forKey:[NSString stringWithFormat:@"%@+Date",rememberTitle]];
    [data writeToURL:path atomically:YES];
}

- (void)readDates:(NSString *)rememberTitle {
    /**
     Loads the contents of a plist into a tableView array.
     */
    
    NSMutableDictionary *data;
    _fileManager = [NSFileManager defaultManager];
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    NSURL *path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Dates.remember"]];
    
    if (![_fileManager fileExistsAtPath:[path path]])
    {
        path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Dates.remember"]];
        //NSLog(@"Creating file...");
    } else {
        //NSLog(@"File exists at path!");
    }
    
    if ([_fileManager fileExistsAtPath:[path path]])
    {
        data = [[NSMutableDictionary alloc] initWithContentsOfFile:[path path]];
    } else {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
    }
    
    loadedDateName = [data objectForKey:[NSString stringWithFormat:@"%@+Date",rememberTitle]];
}

#pragma mark - URL Management

- (void)writeURL:(NSURL *)url title:(NSString *)rememberTitle; {
    /**
     Write the NSDictionary into the plist and insert the objects into their appropriate identifiers.
     */
    
    NSMutableDictionary *data;
    _fileManager = [NSFileManager defaultManager];
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    NSURL *path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/URL.remember"]];
    
    if (![_fileManager fileExistsAtPath:[path path]]) // watch out for the !
    {
        path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/URL.remember"]];
        //NSLog(@"Creating file...");
    }
    
    if ([_fileManager fileExistsAtPath:[path path]])
    {
        data = [[NSMutableDictionary alloc] initWithContentsOfURL:path];
        //NSLog(@"File exists at path!");
    } else {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
    }
    
    //NSLog(@"Writing URL: %@",url);
    if (url) {
        [data setObject:[url absoluteString]
                 forKey:[NSString stringWithFormat:@"%@+URL",rememberTitle]];
        [data writeToURL:path atomically:YES];
    }
}

- (NSURL *)readURL:(NSString *)rememberTitle; {
    /**
     Loads the contents of a plist into a tableView array.
     */
    
    NSMutableDictionary *data;
    _fileManager = [NSFileManager defaultManager];
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    NSURL *path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/URL.remember"]];
    
    if (![_fileManager fileExistsAtPath:[path path]])
    {
        path = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"URL.remember"]];
        //NSLog(@"Creating file...");
    } else {
        //NSLog(@"File exists at path!");
    }
    
    if ([_fileManager fileExistsAtPath:[path path]])
    {
        data = [[NSMutableDictionary alloc] initWithContentsOfFile:[path path]];
    } else {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
    }
    
    NSURL *url = [NSURL URLWithString:[data objectForKey:[NSString stringWithFormat:@"%@+URL",rememberTitle]]];
    //NSLog(@"Returning URL: %@ and key: %@",url,[NSString stringWithFormat:@"%@+URL",rememberTitle]);
    return url;
}

@end
