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
#import "AlertView+Input.h"
#import "RMSpotlight.h"
#import "RMParallax.h"
#import <SWTableViewCell.h>

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

@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UITableView *reminderTable;
@property (weak, nonatomic) IBOutlet UITextField *noteField;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedController;
@property (weak, nonatomic) id previewingContext;
@property (weak, nonatomic) id tapticEngine;

@property (copy, nonatomic) UIRefreshControl *refresh;
@property (copy, nonatomic) UITableViewController *tableViewController;
@property (copy, nonatomic) NotesTableCell *cell;
@property (weak, nonatomic) BOZPongRefreshControl *pongRefreshControl;

@property (copy, nonatomic) RMAudio *sound;
@property (copy, nonatomic) RMDataManager *dManager;
@property (copy, nonatomic) RMSpotlight *spotlight;
@property (copy, nonatomic) RMParallax *parallax;
@property (copy, nonatomic) SCLAlertView *alert;

@end

@implementation NotesTableController

# pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _reminderTable.dataSource = self;
    _reminderTable.delegate = self;
    _noteField.delegate = self;
    _sound = [RMAudio new];
    _dManager = [RMDataManager new];
    _alert = [SCLAlertView new];
    _spotlight = [RMSpotlight new];
    _parallax = [RMParallax new];
    _titlesCurrent = [NSMutableArray new];
    
    [self sizeHeaderToFit];
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
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Pong"] == false)
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
    [_parallax setMinimumValue:-5];
    [_parallax setMaximumValue: 5];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self readFileContents:@"Notes"];
    [_reminderTable reloadData];
    [self update];
}

- (void)viewDidLayoutSubviews
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Pong"] == true)
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
        NSString *string = [NSString stringWithFormat:@"%@",_titlesCurrent[indexPath.row]];
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
    SCLAlertView *alertView = [[SCLAlertView alloc] init];
    UITextField *textField = [alertView addTextField:@"i.e. Pick Up Milk"];
    __weak typeof(self) weakSelf = self;
    [alertView addButton:@"Done" actionBlock:^(void)
    {
        if ([weakSelf.titlesCurrent containsObject:textField.text])
        {
            SCLAlertView *alert2 = [SCLAlertView new];
            alert2.shouldDismissOnTapOutside = YES;
            [alert2 showCustom:weakSelf
                         image:[UIImage imageNamed:@"Thin Delete"]
                        color:[UIColor flatPurpleColorDark]
                        title:@"Remember"
                     subTitle:@"You already have a note with the same name.\nPlease choose a new one."
             closeButtonTitle:@"Dismiss"
                     duration:0.0f];
            alert2.backgroundType = Blur;
        } else {
            // 1. Read (validate file before rewriting)
            // 2. Add object to array (add note title)
            // 3. Write (overwrite file after adding new value)
            // 4. Read (validate that title was added)
            // 5. Refresh (display updated array and contents)
            [weakSelf readFileContents:@"Notes"];
            [weakSelf.titlesCurrent addObject:textField.text];
            [weakSelf writeFileContents:@"Notes"];
            [weakSelf readFileContents:@"Notes"];
            [weakSelf.reminderTable reloadData];
        }
    }];
    alertView.backgroundType = Blur;
    [alertView showCustom:self
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
            if ([self.titlesCurrent containsObject:textField.text])
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
                [self.titlesCurrent addObject:_noteField.text];
                [self writeFileContents:@"Notes"];
                [self readFileContents:@"Notes"];
                [self.reminderTable reloadData];
                [self.noteField setText:@""];
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
            if ([self.titlesCurrent containsObject:field.text])
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

- (void)sizeHeaderToFit
{
    UIView *header = self.reminderTable.tableHeaderView;
    
    [header setNeedsLayout];
    [header layoutIfNeeded];
    
    CGFloat height = [header systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    CGRect frame = header.frame;
    
    frame.size.height = height;
    header.frame = frame;
    
    self.reminderTable.tableHeaderView = header;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_segmentedController.selectedSegmentIndex == 0) {
        return _headerView;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_segmentedController.selectedSegmentIndex == 0) {
        return _noteField.frame.size.height+10;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 96;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return [_titlesCurrent count];
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
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 96, self.view.bounds.size.width, 10)];
    lineView.backgroundColor = [UIColor clearColor];
    [_cell.contentView addSubview:lineView];
    
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
        NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                               @"group.com.solarpepper.Remember"];
        NSURL *container = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.remember",_titlesCurrent[indexPath.row]]];
        NSMutableDictionary *sharedData = [[NSMutableDictionary alloc] initWithContentsOfURL:container];
        
        cell.title.text = _titlesCurrent[indexPath.row];
        NSString *author = [sharedData objectForKey:[NSString stringWithFormat:@"%@+Author",_titlesCurrent[indexPath.row]]];
        
        if ([sharedData objectForKey:[NSString stringWithFormat:@"%@+Author",_titlesCurrent[indexPath.row]]] == nil)
        {
            cell.author.text = [NSString stringWithFormat:@"Author: "];
        } else {
            cell.author.text = [NSString stringWithFormat:@"Author: %@",author];
        }
        
        NSURL *dateContainer = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Dates.remember"]];
        NSMutableDictionary *dateManager = [[NSMutableDictionary alloc] initWithContentsOfURL:dateContainer];
        
        NSDate *date = [dateManager objectForKey:[NSString stringWithFormat:@"%@+Date",_titlesCurrent[indexPath.row]]];
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
        if ([dateManager objectForKey:[NSString stringWithFormat:@"%@+Date",_titlesCurrent[indexPath.row]]] == nil)
        {
            cell.reminder.text = [NSString stringWithFormat:@"Remember: "];
        } else {
            if ([date timeIntervalSinceNow] > 0.0) {
                cell.reminder.text = [NSString stringWithFormat:@"Remember: %@",string];
            } else {
                cell.reminder.text = [NSString stringWithFormat:@"Remember: "];
            }
        }
        
        NSString *photoPath = [[containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/"]] path];
        NSString *imageName = [photoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",_titlesCurrent[indexPath.row]]];
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
            [cell.customBackground hnk_setImageFromFile:imageName];
            
            cell.title.textColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:[UIColor colorWithComplementaryFlatColorOf:
                                                                                     AverageColorFromImage(cell.customBackground.image)] isFlat:YES];
            cell.reminder.textColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:[UIColor colorWithComplementaryFlatColorOf:
                                                                                        AverageColorFromImage(cell.customBackground.image)] isFlat:YES];
            cell.author.textColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:[UIColor colorWithComplementaryFlatColorOf:
                                                                                      AverageColorFromImage(cell.customBackground.image)] isFlat:YES];
            //[_parallax addParallaxToView:_cell.customBackground];

        } else {
            cell.customBackground.image = nil;
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

#pragma mark - Cell Selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self chooseCellSound];
    DetailViewController *controller = [DetailViewController new];
    controller.rememberTitle = _titlesCurrent[indexPath.row];
    [self performSegueWithIdentifier:@"pushCell" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailViewController *destViewController = segue.destinationViewController;
    NSIndexPath *indexPath = [_reminderTable indexPathForSelectedRow];
    NSString *string = [NSString stringWithFormat:@"%@",_titlesCurrent[indexPath.row]];
    destViewController.rememberTitle = string;
}

- (void)performSegueFromNotification:(UILocalNotification *)notification {
    DetailViewController *detailView = [DetailViewController new];
    if (notification) {
        NSDictionary *data = notification.userInfo;
        NSString *rememberTitle = [data objectForKey:@"Title"];
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
                // Checkmark Button - Complete Task
                NSIndexPath *indexPath = [_reminderTable indexPathForCell:cell];
                [self readFileContents:@"Notes"];
                
                // Move data to other completed.remember file
                [_dManager addContentsToTable:[NSString stringWithFormat:@"%@",_titlesCurrent[indexPath.row]]
                                containerID:@"group.com.solarpepper.Remember"
                                   fileName:@"Completed"];
                [self readFileContents:@"Notes"];
                
                //
                [_titlesCurrent removeObjectAtIndex:[indexPath row]];
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
                NSString *deleteName = _titlesCurrent[indexPath.row];
                [self readFileContents:@"Completed"];
                [_dManager deleteDataContentsWithTitle:deleteName container:@"group.com.solarpepper.Remember"];
                [_spotlight removeItemFromCoreSpotlightWithName:_titlesCurrent[indexPath.row]];
                // 2. Cancel reminder for user
                NSString *IDToCancel = [NSString stringWithFormat:@"%@",_titlesCurrent[indexPath.row]];
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
                        alert.backgroundType = Blur;
                        [cell hideUtilityButtonsAnimated:YES];
                        break;
                    }
                }
                [cell hideUtilityButtonsAnimated:YES];
                
                // 3. Continue deleting data
                [_titlesCurrent removeObjectAtIndex:[indexPath row]];
                [_reminderTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [self writeFileContents:@"Completed"];
                [self readFileContents:@"Favorites"];
                [_titlesCurrent removeObjectIdenticalTo:deleteName];
                [self writeFileContents:@"Favorites"];
                [self readFileContents:@"Completed"];
                [self deleteCellSound];
                //[self envokeFeedback];
                
                [_reminderTable reloadData];
                break;
            }
        }
        case 1:
        {
            // Checkmark - Complete Task
            NSIndexPath *indexPath = [_reminderTable indexPathForCell:cell];
            [self readFileContents:@"Favorites"];
            NSMutableArray *favorites = _dManager.loadedTitles;
            if (_segmentedController.selectedSegmentIndex == 0)
            {
                [self readFileContents:@"Notes"];
            }
            if (_segmentedController.selectedSegmentIndex == 1)
            {
                [self readFileContents:@"Completed"];
            }
            
            // Move data to favorites.rememeber file
            if ([favorites containsObject:_titlesCurrent[indexPath.row]])
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
                [_dManager addContentsToTable:[NSString stringWithFormat:@"%@",_titlesCurrent[indexPath.row]]
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
    NSURL *container = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.remember",_titlesCurrent[indexPath.row]]];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfURL:container];
    
    NSString *photoPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imageName = [photoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",_titlesCurrent[indexPath.row]]];
    UIImage *sharedImage = [UIImage imageWithContentsOfFile:imageName];
    //NSLog(@"Image Path: %@",sharedImage);
    // Load save data values
    switch (index)
    {
        case 0:
        {
            NSArray *activities = [[NSArray alloc] initWithObjects:
                                   [data objectForKey:[NSString stringWithFormat:@"%@+Note",_titlesCurrent[indexPath.row]]], sharedImage, nil];
            
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
            NSString *IDToCancel = [NSString stringWithFormat:@"%@",_titlesCurrent[indexPath.row]];
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
                    alert.backgroundType = Blur;
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
    [_sound playSoundWithName:@"2" extension:@"caf"];
}

- (void)deleteCellSound
{
    [_sound playSoundWithName:@"4" extension:@"caf"];
}

- (void)completeCellSound
{
    [_sound playSoundWithName:@"3" extension:@"caf"];
}

- (void)favoriteCellSound
{
    [_sound playSoundWithName:@"5" extension:@"caf"];
}

#pragma mark - Data Management

- (void)writeFileContents:(NSString *)name {
    [_dManager writeTableContentsFromArray:_titlesCurrent
                             containerID:@"group.com.solarpepper.Remember"
                                fileName:name];
}

- (void)readFileContents:(NSString *)name {
    [_dManager readTableContentsFromContainerID:@"group.com.solarpepper.Remember"
                                       fileName:name];
    _titlesCurrent = _dManager.loadedTitles;
}

@end
