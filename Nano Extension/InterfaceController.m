//
//  InterfaceController.m
//  Nano Extension
//
//  Created by Keeton on 4/12/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import "InterfaceController.h"
#import "NanoCell.h"

@interface InterfaceController()
@property (strong, nonatomic) IBOutlet WKInterfaceTable *nanoTable;
@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSMutableArray *nanoTitles;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self initializeTableView];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    _nanoTitles = nil;
}

- (void)initializeTableView {
    [self readTableContentsFromContainerID:@"group.com.solarpepper.Remember" fileName:@"Notes"];
    NSLog(@"Nano Titles: %@",_nanoTitles);
    [_nanoTable setRowTypes:[_nanoTitles copy]];
    for (NSInteger i = 0; i < _nanoTable.numberOfRows; i++)
    {
        NSObject *row = [_nanoTable rowControllerAtIndex:i];
        NanoCell *cellrow = (NanoCell *) row;
        [cellrow.cellDisplayName setText:[_nanoTitles objectAtIndex:i]];
    }
}

- (void)readTableContentsFromContainerID:(NSString *)containerID fileName:(NSString*)fileName {
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
    
    _nanoTitles = [[NSMutableArray alloc] initWithArray:[data objectForKey:@"Titles"]];
}

@end



