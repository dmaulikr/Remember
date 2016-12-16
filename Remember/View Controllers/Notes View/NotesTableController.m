//
//  SecondViewController.m
//  Remember
//
//  Created by Keeton on 10/12/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import "NotesTableController.h"
#import "NotesTableCell.h"
#import "DetailViewController.h"
#import "RMSpotlight.h"
#import "SWTableViewCell.h"
#import "RMNote.h"
#import "RMNoteLoader.h"

@interface NotesTableController ()
<
UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate,
SWTableViewCellDelegate,
MFMailComposeViewControllerDelegate,
UIActionSheetDelegate,
UIScrollViewDelegate,
UIViewControllerPreviewingDelegate
>

@property (weak, nonatomic) IBOutlet UIImageView            *background;
@property (weak, nonatomic) IBOutlet UITableView            *reminderTable;
@property (weak, nonatomic) IBOutlet UITextField            *noteField;
@property (weak, nonatomic) IBOutlet UIView                 *headerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl     *segmentedController;
@property (weak, nonatomic) id                              previewingContext;
@property (weak, nonatomic) id                              tapticEngine;

@property (copy, nonatomic) UIRefreshControl                *refresh;
@property (copy, nonatomic) UITableViewController           *tableViewController;
@property (copy, nonatomic) NotesTableCell                  *cell;
@property (weak, nonatomic) BOZPongRefreshControl           *pongRefreshControl;

@property (copy, nonatomic) RMAudio                         *audio;
@property (copy, nonatomic) RMDataManager                   *dataManager;
@property (copy, nonatomic) RMSpotlight                     *spotlight;
@property (copy, nonatomic) SCLAlertView                    *alert;

@property (strong, nonatomic) RMNote                        *note;
@property (strong, nonatomic) RMNote                        *list;
@property (strong, nonatomic) RMNote                        *completed;
@property (strong, nonatomic) RMNote                        *favorites;
@property (strong, nonatomic) RMNoteLoader                  *loader;
@property (strong, nonatomic) NSCoder                       *coder;

@end

@implementation NotesTableController
@synthesize titles;
@synthesize listComplete;
@synthesize listFavorites;

# pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:[NSMutableData data]];
    _note = [[RMNote alloc] initWithCoder:_coder];
    _list = [[RMNote alloc] initWithName:@"Notes"];
    _completed = [[RMNote alloc] initWithName:@"Completed"];
    _favorites = [[RMNote alloc] initWithName:@"Favorites"];
    _loader = [[RMNoteLoader alloc] init];
    
    _reminderTable.dataSource = self;
    _reminderTable.delegate = self;
    _noteField.delegate = self;
    
    _audio = [RMAudio new];
    _dataManager = [RMDataManager new];
    _alert = [SCLAlertView new];
    _spotlight = [RMSpotlight new];
    
    titles = [NSMutableArray new];
    listComplete = [NSMutableArray new];
    listFavorites = [NSMutableArray new];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(panGestureRecognized:)];
    [self.view addGestureRecognizer:pan];
    
    /*
    UILongPressGestureRecognizer *hold = [[UILongPressGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(renameCell)];
    [hold setMinimumPressDuration:1.0];
    [_cell addGestureRecognizer:hold];
    */
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"RMPongRefresh"] == false)
    {
        _refresh = [UIRefreshControl new];
        _refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull To Refresh"];
        [_refresh addTarget:self action:@selector(update) forControlEvents:UIControlEventValueChanged];
        _tableViewController = [UITableViewController new];
        _tableViewController.tableView = _reminderTable;
        [_tableViewController setRefreshControl:_refresh];
    }
   
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"Arimo"
                                                size:12],
                                NSFontAttributeName,nil];
    [_segmentedController setTitleTextAttributes:attributes
                                        forState:UIControlStateNormal];
    if ([self isForceTouchAvailable]) {
        self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self update];
}

- (void)viewDidLayoutSubviews
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"RMPongRefresh"] == true)
    {
        self.pongRefreshControl = [BOZPongRefreshControl attachToTableView:_reminderTable
                                                         withRefreshTarget:self
                                                          andRefreshAction:@selector(update)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

# pragma mark - Force Touch

- (BOOL)isForceTouchAvailable {
    BOOL isForceTouchAvailable = NO;
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        isForceTouchAvailable = self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    }
    return isForceTouchAvailable;
}

- (UIViewController *)previewingContext:(id )previewingContext viewControllerForLocation:(CGPoint)location{
    // check if we're not already displaying a preview controller (WebViewController is my preview controller)
    if ([self.presentedViewController isKindOfClass:[DetailViewController class]]) {
        return nil;
    }
    
    CGPoint cellPostion = [_reminderTable convertPoint:location fromView:self.view];
    NSIndexPath *path = [_reminderTable indexPathForRowAtPoint:cellPostion];
    
    if (path)
    {
        DetailViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"detailController"];
        NSIndexPath *indexPath = [_reminderTable indexPathForSelectedRow];
        NSString *string = [NSString stringWithFormat:@"%@",titles[indexPath.row]];
        destViewController.rememberTitle = string;
        return destViewController;
    }
    return nil;
}

- (void)previewingContext:(id )previewingContext commitViewController: (UIViewController *)viewControllerToCommit {
    // if you want to present the selected view controller as it self us this:
    // [self presentViewController:viewControllerToCommit animated:YES completion:nil];
    
    // to render it with a navigation controller (more common) you should use this:
    [self.navigationController showViewController:viewControllerToCommit sender:nil];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if ([self isForceTouchAvailable]) {
        if (!self.previewingContext) {
            self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
        }
    } else {
        if (self.previewingContext) {
            [self unregisterForPreviewingWithContext:self.previewingContext];
            self.previewingContext = nil;
        }
    }
}

# pragma mark - Gesture Management

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    CGPoint velocity = [sender velocityInView:self.view];
    if (velocity.x > 0) {
        [self.frostedViewController panGestureRecognized:sender];
    }
}

# pragma mark - Menu Management

- (IBAction)showMenu {
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController presentMenuViewController];
}

# pragma mark - Alert Management

- (IBAction)addReminder:(id)sender {
    SCLAlertView *alert = [SCLAlertView new];
    UITextField *textField = [alert addTextField:@"i.e. Pick Up Milk"];
    __weak typeof(self) weakSelf = self;
    [alert addButton:@"Done" actionBlock:^(void)
    {
        if ([weakSelf.titles containsObject:textField.text])
        {
            //SCLAlertView *alert2 = [SCLAlertView new];
            weakSelf.alert.shouldDismissOnTapOutside = YES;
            [weakSelf.alert showCustom:weakSelf
                         image:[UIImage imageNamed:@"Thin Delete"]
                        color:[UIColor flatPurpleColorDark]
                        title:@"Remember"
                     subTitle:@"You already have a note with the same name.\nPlease choose a new one."
             closeButtonTitle:@"Dismiss"
                     duration:0.0f];
            weakSelf.alert.backgroundType = SCLAlertViewBackgroundBlur;
        } else {
            // 1. Read (validate file before rewriting)
            // 2. Add object to array (add note title)
            // 3. Write (overwrite file after adding new value)
            // 4. Read (validate that title was added)
            // 5. Refresh (display updated array and contents)
                //[weakSelf readFileContents:@"Notes"];
            if (titles) {
                [weakSelf.titles addObject:textField.text];
                [weakSelf writeFileContents:@"Notes"];
                [weakSelf readFileContents:@"Notes"];
                [weakSelf.reminderTable reloadData];
                [self.noteField setText:@""];
            } else {
                titles = [NSMutableArray new];
                [weakSelf.titles addObject:textField.text];
                _list.array = titles;
                NSLog(@"Titles: %@", titles);
                NSLog(@"Set List: %@", _list.array);
                [weakSelf writeFileContents:@"Notes"];
                [weakSelf readFileContents:@"Notes"];
                [weakSelf.reminderTable reloadData];
                [self.noteField setText:@""];
            }
        }
    }];
    alert.backgroundType = SCLAlertViewBackgroundBlur;
    [alert showCustom:self
                image:[UIImage imageNamed:@"Sticky Note"]
                color:[UIColor flatPurpleColorDark]
              title:@"Remember"
           subTitle:@"Please provide a name for your remember:"
   closeButtonTitle:@"Cancel"
           duration:0.0f];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    dispatch_async(dispatch_get_main_queue(), ^{
        [textField resignFirstResponder];
        if (![_noteField.text isEqual: @""])
        {
            [self readFileContents:@"Notes"];
            if ([self.titles containsObject:textField.text])
            {
                SCLAlertView *alert = [SCLAlertView new];
                [alert showCustom:self
                            image:[UIImage imageNamed:@"Sticky Note"]
                            color:[UIColor flatPurpleColorDark]
                            title:@"Remember"
                         subTitle:@"You already have a note with the same name.\nPlease choose a new one."
                 closeButtonTitle:@"Dismiss"
                         duration:0.0f];
            } else {
                if (titles) {
                    [self.titles addObject:_noteField.text];
                    [self writeFileContents:@"Notes"];
                    [self readFileContents:@"Notes"];
                    [self.reminderTable reloadData];
                    [self.noteField setText:@""];
                } else {
                    titles = [NSMutableArray new];
                    [self.titles addObject:_noteField.text];
                    _list.array = titles;
                    NSLog(@"Titles: %@", titles);
                    NSLog(@"Set List: %@", _list.array);
                    [self writeFileContents:@"Notes"];
                    [self readFileContents:@"Notes"];
                    [self.reminderTable reloadData];
                    [self.noteField setText:@""];
                }
            }
        }
    });
    return NO;
}

- (void)renameCell {
    SCLAlertView *alertView = [[SCLAlertView alloc] init];
    UITextField *field = [alertView addTextField:@"i.e. Pick Up Milk"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![_noteField.text isEqual: @""])
        {
            [self readFileContents:@"Notes"];
            if ([self.titles containsObject:field.text])
            {
                SCLAlertView *alert = [SCLAlertView new];
                [alert showCustom:self
                            image:[UIImage imageNamed:@"Sticky Note"]
                            color:[UIColor flatPurpleColorDark]
                            title:@"Remember"
                         subTitle:@"You already have a note with the same name.\nPlease choose a new one."
                 closeButtonTitle:@"Dismiss"
                         duration:0.0f];
            } else {
                [alertView addButton:@"Done" actionBlock:^(void)
                {
                    /*
                    [self.titles addObject:_noteField.text];
                    [self writeFileContents:@"Notes"];
                    [self readFileContents:@"Notes"];
                    [self.reminderTable reloadData];
                    [self.noteField setText:@""];
                    */
                }];
            }
        }
    });
}

#pragma mark - TableView Management

- (IBAction)segmentValueChanged:(id)sender {
    if (_segmentedController.selectedSegmentIndex == 0) {
        // Current
        [self readFileContents:@"Notes"];
        [_noteField setEnabled:true];
        [_noteField setAlpha:100.0];
        [_reminderTable reloadData];
    } else {
        // Completed
        [self readFileContents:@"Completed"];
        [_noteField setEnabled:false];
        [_noteField setAlpha:50.0];
        [_reminderTable reloadData];
    }
}

- (void)update
{
    if (_segmentedController.selectedSegmentIndex == 0)
        [self readFileContents:@"Notes"];
    else
        [self readFileContents:@"Completed"];
    [_reminderTable reloadData];
    [_refresh endRefreshing];
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       [self.pongRefreshControl finishedLoading];
                   });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 96;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return [titles count];
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell; {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    //This is compensated for in the swipable actions.
    //We don't need to use the default UI method.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Define Variables
    static NSString *cellIdentifier = @"noteCell";
    NotesTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    _cell = cell;
    tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
    // Make the TableView Actions
    
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    if (_segmentedController.selectedSegmentIndex == 0) {
    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.595 green:0.750 blue:0.000 alpha:0.750]
                                                icon:[UIImage imageNamed:@"Thin Check"]];
    }
    
    if (_segmentedController.selectedSegmentIndex == 1) {
    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.850 green:0.218 blue:0.159 alpha:0.750]
                                                icon:[UIImage imageNamed:@"Thin Delete"]];
    }
    
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.000 green:0.128 blue:1.000 alpha:0.750]
                                                icon:[UIImage imageNamed:@"Heart"]];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.518 green:0.582 blue:0.586 alpha:0.750]
                                                 icon:[UIImage imageNamed:@"Share"]];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.518 green:0.582 blue:0.586 alpha:0.750]
                                                 icon:[UIImage imageNamed:@"Silent"]];
    
    cell.leftUtilityButtons = leftUtilityButtons;
    cell.rightUtilityButtons = rightUtilityButtons;
    cell.delegate = self;
    
    if (cell == nil) {
        cell = [[NotesTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0)
    {
        RMNote *note = [[RMNote alloc] initWithName:titles[indexPath.row]];
        cell.title.text = titles[indexPath.row];
        NSString *author = note.author;
        
        if (note.author == nil)
        {
            cell.author.text = [NSString stringWithFormat:@"Author: "];
        } else {
            cell.author.text = [NSString stringWithFormat:@"Author: %@",author];
        }
        
        NSDate *date = note.fire;
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"MM/dd/yyyy 'at' hh:mm"];
        NSString *string;
        if ([date timeIntervalSinceNow] > 0.0) {
            //NSLog(@"Date Has Not Passed");
            string = [formatter stringFromDate:date];
        } else {
            //NSLog(@"Date Has Passed");
            string = @"";
        }
        if (note.fire == nil)
        {
            cell.reminder.text = [NSString stringWithFormat:@"Remember: "];
        } else {
            if ([date timeIntervalSinceNow] > 0.0) {
                cell.reminder.text = [NSString stringWithFormat:@"Remember: %@",string];
            } else {
                cell.reminder.text = [NSString stringWithFormat:@"Remember: "];
            }
        }
        
        NSURL *container = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.solarpepper.Remember"];
        NSString *photoPath = [[container URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/"]] path];
        NSString *imageName = [photoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",titles[indexPath.row]]];
        UIImage *image = note.image;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:imageName])
        {
            HNKCacheFormat *format = [HNKCache sharedCache].formats[@"thumbnail"];
            if (!format)
            {
                format = [[HNKCacheFormat alloc] initWithName:@"thumbnail"];
                format.size = CGSizeMake(cell.frame.size.width+20, cell.frame.size.height+20);
                format.scaleMode = HNKScaleModeAspectFill;
                format.compressionQuality = 0.5;
                format.diskCapacity = 10 * 1024 * 1024; // 10MB
                format.preloadPolicy = HNKPreloadPolicyAll;
            }
            //
            [cell.customBackground hnk_setImageFromFile:imageName];
            
            cell.title.textColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:[UIColor colorWithComplementaryFlatColorOf:
                                                                                     AverageColorFromImage(cell.customBackground.image)] isFlat:YES];
            cell.reminder.textColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:[UIColor colorWithComplementaryFlatColorOf:
                                                                                        AverageColorFromImage(cell.customBackground.image)] isFlat:YES];
            cell.author.textColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:[UIColor colorWithComplementaryFlatColorOf:
                                                                                      AverageColorFromImage(cell.customBackground.image)] isFlat:YES];
        } else {
            //
            cell.customBackground.image = image;
            cell.title.textColor = [UIColor flatBlackColor];
            cell.reminder.textColor = [UIColor flatBlackColor];
            cell.author.textColor = [UIColor flatBlackColor];
        }
    }
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.pongRefreshControl scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.pongRefreshControl scrollViewDidEndDragging];
}

#pragma mark - Cell Selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self chooseCellSound];
    DetailViewController *controller = [DetailViewController new];
    controller.rememberTitle = titles[indexPath.row];
    [self performSegueWithIdentifier:@"pushCell" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailViewController *destViewController = segue.destinationViewController;
    NSIndexPath *indexPath = [_reminderTable indexPathForSelectedRow];
    NSString *string = [NSString stringWithFormat:@"%@",titles[indexPath.row]];
    destViewController.rememberTitle = string;
}

- (void)performSegueFromNotification:(UNNotificationRequest *)notification {
    DetailViewController *detailView = [DetailViewController new];
    if (notification) {
        //NSDictionary *data = notification.content.userInfo;
        NSString *rememberTitle = notification.content.title;
        detailView.rememberTitle = rememberTitle;
        [self performSegueWithIdentifier:@"cellPush" sender:self];
    }
}

#pragma mark - Swipable Action Selection

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            if (_segmentedController.selectedSegmentIndex == 0)
            {
                #pragma mark - TODO: Move to new RMNote system
                // Checkmark Button - Complete Task
                NSIndexPath *indexPath = [_reminderTable indexPathForCell:cell];
                [self readFileContents:@"Notes"];
                
                // Move data to other completed.remember file
                [_dataManager addContentsToTable:[NSString stringWithFormat:@"%@",titles[indexPath.row]]
                                containerID:@"group.com.solarpepper.Remember"
                                   fileName:@"Completed"];
                [self readFileContents:@"Notes"];
                
                //
                [titles removeObjectAtIndex:[indexPath row]];
                [_reminderTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [self writeFileContents:@"Notes"];
                [self readFileContents:@"Notes"];
                [self completeCellSound];
                //[self envokeFeedback];
                
                [_reminderTable reloadData];
                break;

            } else {
                //    Deleting note data
                // 1. Gather required note information
                NSIndexPath *indexPath = [_reminderTable indexPathForCell:cell];
                NSString *deleteName = titles[indexPath.row];
                [self readFileContents:@"Completed"];
                [_dataManager deleteDataContentsWithTitle:deleteName container:@"group.com.solarpepper.Remember"];
                [_spotlight removeItemFromCoreSpotlightWithName:titles[indexPath.row]];
                
                // 2. Cancel reminder for user
                NSString *IDToCancel = [NSString stringWithFormat:@"%@",titles[indexPath.row]];
                UILocalNotification *notificationToCancel = nil;
                for(UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications])
                {
                    if([[notification.userInfo objectForKey:@"ID"] isEqualToString:IDToCancel])
                    {
                        notificationToCancel = notification;
                        [[UIApplication sharedApplication] cancelLocalNotification:notificationToCancel];
                        SCLAlertView *alert = [SCLAlertView new];
                        alert.shouldDismissOnTapOutside = YES;
                        [alert showCustom:self
                                    image:[UIImage imageNamed:@"Silent"]
                                    color:[UIColor flatPurpleColorDark]
                                    title:@"Notice"
                                 subTitle:@"You deleted a note that still had an active reminder.\nBecause it has been deleted, you will no longer be reminded."
                         closeButtonTitle:@"Dismiss"
                                 duration:0.0f];
                        alert.backgroundType = SCLAlertViewBackgroundBlur;
                        [cell hideUtilityButtonsAnimated:YES];
                        break;
                    }
                }
                [cell hideUtilityButtonsAnimated:YES];
                
                // 3. Continue deleting data
                [titles removeObjectAtIndex:[indexPath row]];
                [_reminderTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [self writeFileContents:@"Completed"];
                [self readFileContents:@"Favorites"];
                [titles removeObjectIdenticalTo:deleteName];
                [self writeFileContents:@"Favorites"];
                [self readFileContents:@"Completed"];
                [self deleteCellSound];
                
                [_reminderTable reloadData];
                break;
            }
        }
        case 1:
        {
            // Checkmark - Complete Task
            NSIndexPath *indexPath = [_reminderTable indexPathForCell:cell];
            [self readFileContents:@"Favorites"];
            NSMutableArray *favorites = _dataManager.loadedTitles;
            if (_segmentedController.selectedSegmentIndex == 0)
            {
                [self readFileContents:@"Notes"];
            }
            if (_segmentedController.selectedSegmentIndex == 1)
            {
                [self readFileContents:@"Completed"];
            }
            
            // Move data to favorites.rememeber file
            if ([favorites containsObject:titles[indexPath.row]])
            {
                [cell hideUtilityButtonsAnimated:YES];
                // Don't add to favorites list
                [_alert showCustom:self
                             image:[UIImage imageNamed:@"Sticky Note"]
                             color:[UIColor flatPurpleColorDark]
                             title:@"Error"
                          subTitle:@"This note is already in your favorites list."
                  closeButtonTitle:@"Dismiss"
                          duration:0.0f];
            } else {
                [cell hideUtilityButtonsAnimated:YES];
                [_dataManager addContentsToTable:[NSString stringWithFormat:@"%@",titles[indexPath.row]]
                                  containerID:@"group.com.solarpepper.Remember"
                                     fileName:@"Favorites"];
                [self readFileContents:@"Favorites"];
                [self readFileContents:@"Notes"];
                [self favoriteCellSound];
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    // Load plist path
    NSIndexPath *indexPath = [_reminderTable indexPathForCell:cell];
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    NSURL *container = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.remember",titles[indexPath.row]]];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfURL:container];
    
    NSString *photoPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imageName = [photoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",titles[indexPath.row]]];
    UIImage *sharedImage = [UIImage imageWithContentsOfFile:imageName];
    //NSLog(@"Image Path: %@",sharedImage);
    // Load save data values
    switch (index)
    {
        case 0:
        {
            NSArray *activities = [[NSArray alloc] initWithObjects:
                                   [data objectForKey:[NSString stringWithFormat:@"%@+Note",titles[indexPath.row]]], sharedImage, nil];
            
            UIActivityViewController *activity = [[UIActivityViewController alloc]
                                                  initWithActivityItems:activities
                                                  applicationActivities:nil];
            activity.popoverPresentationController.sourceView = self.navigationController.navigationBar;
            activity.excludedActivityTypes = @[UIActivityTypePostToVimeo, UIActivityTypeAddToReadingList];
            [self presentViewController:activity animated:YES completion:nil];
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1:
        {
            // Cancel reminder for user
            NSString *IDToCancel = [NSString stringWithFormat:@"%@",titles[indexPath.row]];
            UILocalNotification *notificationToCancel = nil;
            for(UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications])
            {
                if([[notification.userInfo objectForKey:@"ID"] isEqualToString:IDToCancel])
                {
                    notificationToCancel = notification;
                    [[UIApplication sharedApplication] cancelLocalNotification:notificationToCancel];
                    SCLAlertView *alert = [SCLAlertView new];
                    alert.shouldDismissOnTapOutside = YES;
                    [alert showCustom:self
                                image:[UIImage imageNamed:@"Silent"]
                                color:[UIColor flatPurpleColorDark]
                                title:@"Notice"
                             subTitle:@"You will no longer be reminded about this note."
                     closeButtonTitle:@"Dismiss"
                             duration:0.0f];
                    alert.backgroundType = SCLAlertViewBackgroundBlur;
                    [cell hideUtilityButtonsAnimated:YES];
                    break;
                }
            }
            [cell hideUtilityButtonsAnimated:YES];
        }
            default:
            break;
    }
}

# pragma mark - Audio Managment

- (void)chooseCellSound
{
    [_audio playSoundWithName:@"Select" extension:@"caf"];
}

- (void)completeCellSound
{
    [_audio playSoundWithName:@"Complete" extension:@"caf"];
}

- (void)deleteCellSound
{
    [_audio playSoundWithName:@"Delete" extension:@"caf"];
}

- (void)favoriteCellSound
{
    [_audio playSoundWithName:@"Favorite" extension:@"caf"];
}

#pragma mark - Data Management

- (void)writeFileContents:(NSString *)file {
    _list.array = titles;
    [_list debugNoteContents];
    [_loader saveDataToDiskWithNote:_list andName:file];
    
    //[_dataManager writeTableContentsFromArray:titles
    //                         containerID:@"group.com.solarpepper.Remember"
    //                            fileName:file];
}

- (void)readFileContents:(NSString *)file {
    _list = [_loader loadDataFromDiskWithName:file];
    [_list debugNoteContents];
    if (_list.array) {
        NSLog(@"Note array is allocated.");
        titles = _list.array;
    } else {
        NSLog(@"Note array is nil. Leaving titles alone.");
    }
    
    //[_dataManager readTableContentsFromContainerID:@"group.com.solarpepper.Remember"
    //                                   fileName:name];
    //titles = _dataManager.loadedTitles;
}

@end
