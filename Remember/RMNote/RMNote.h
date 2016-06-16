//
//  RMNote.h
//  Remember
//
//  Created by Keeton on 6/14/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMNote : NSObject
/**
 
 */
- (id)init;
/**
 noteUnattributed returns an unattributed, plain NSString
 for the note. This is simply used for compatibility with
 Remember version 1.0 and all new notes should be created
 with rich text and noteAttributed (NSAttributedString).
 */
@property (strong, nonatomic) NSString *noteUnattributed;
/**
 noteAttributed returns a rich text (attributed) string and
 should be used for all versions of Remember prior to 1.0.
 The extension for all attributed notes should be ".rmb" and
 note ".remember" as was used in Remember 1.0 in order to
 differentiate between filetypes.
 */
@property (strong, nonatomic) NSAttributedString *noteAttributed;
/**
 noteAuthor returns an unattributed string that is used to display
 the note author in the text field above the note itself. All forms
 of the author values are compatible between Remember 1.0 and 2.0.
 */
@property (strong, nonatomic) NSString *noteAuthor;
/**
 noteTitle returns an unattributed string that is used to display
 the note title in the notes list and navigation bar. All forms
 of the author values are compatible between Remember 1.0 and 2.0.
 */
@property (strong, nonatomic) NSString *noteTitle;
/**
 notePhotoPath returns an NSString copy of notePhotoURL for
 compatibility purposes. All new methods should utilize NSURL.
 */
@property (strong, nonatomic) NSString *notePhotoPath;
/**
 notePhotoURL returns an NSURL form of the path to the photo
 assocciated with the corresponding NSNote. This should be used
 in combination with or appart from NSPhotoManager depending on
 future usage and API changes. (RMPhotoManager may change to in
 accordance to URL paths instead of note names.)
 */
@property (strong, nonatomic) NSURL *notePhotoURL;
/**
 noteLocationDictionary contains two (2) keys: latitude & longitude.
 Both the latitude and longitude values are stored as NSNumbers and
 thus can be converted to any form of number desired.
 */
@property (strong, nonatomic) NSDictionary *noteLocationDictionary;
/**
 getNoteVersion will return the version number of the app the note
 is compatible with. All version 1.0 notes are compatible with 2.0
 but 2.0 notes will not open in 1.0 due to the nature of the files.
 */
@property (strong, nonatomic) NSNumber *getNoteVersion;

@end
