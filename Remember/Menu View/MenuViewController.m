//
//  MenuViewController.m
//  Remember
//
//  Created by Keeton on 10/12/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import "MenuViewController.h"
#import "NavigationViewController.h"
#import "NotesTableController.h"
#import "SettingsViewController.h"
#import "AboutViewController.h"
#import "HelpViewController.h"
#import "DetailViewController.h"
#import "MenuViewCell.h"
#import "RMView.h"
#import "SWTableViewCell.h"

@interface MenuViewController ()
<UINavigationControllerDelegate,UIImagePickerControllerDelegate,SWTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *contactImage;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@property (copy, nonatomic) RMAudio *sound;
@property (copy, nonatomic) RMDataManager *dManager;

@property (copy, nonatomic) NSArray *titles;
@property (copy, nonatomic) NSArray *images;
@property (copy, nonatomic) NSMutableArray *favorites;

@end

@implementation MenuViewController
@synthesize contactImage;
@synthesize contactButton;
@synthesize userNameLabel;
@synthesize versionLabel;

# pragma mark - View Management

- (void)viewDidLoad {
    //View did load
    [super viewDidLoad];
    
    REFrostedViewController *frost = [REFrostedViewController new];
    frost.liveBlur = YES;
    
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    _sound = [RMAudio new];
    _dManager = [RMDataManager new];
    
    RMView *corners = [RMView new];
    [corners createViewWithRoundedCornersWithRadius:45.0 andView:self.contactImage];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(selectPhoto)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    [self.contactImage addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *hold = [[UILongPressGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(removePhoto)];
    hold.numberOfTouchesRequired = 1;
    hold.numberOfTapsRequired = 1;
    hold.minimumPressDuration = 1.0;
    
    [self.contactImage addGestureRecognizer:hold];
    [self.contactImage addGestureRecognizer:tap];
    [self.contactImage setUserInteractionEnabled:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    //View will appear
    [super viewWillAppear:animated];
    [self updateDateLabel];
    [self loadPicture];
    [self readFileContents:@"Favorites"];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Default Author"])
    {
        self.userNameLabel.text = @"Remember";
    }
    else
    {
        self.userNameLabel.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"Default Author"]];
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"Default Author"] isEqualToString:@""])
    {
        self.userNameLabel.text = @"Remember";
    }
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    //View did appear
    [super viewDidAppear:animated];
    //[self menuOpeningSound];
}

- (void)viewWillDisappear:(BOOL)animated {
    //View will disappear
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Table View Management

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return 54;
    } else {
        return 108;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0) {
        return 3;
    }
    if (sectionIndex == 1) {
        return [_favorites count];
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"Arimo" size:17];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0) {
        return nil;
    }
    if (sectionIndex == 1) {
        UITextView *text = [UITextView new];
        [text setFont:[UIFont fontWithName:@"Arimo" size:14]];
        [text setText:@"Favorites:"];
        [text setFrame:CGRectMake(0.f, 0.f, 320.f, 32.f)];
        [text setBackgroundColor:[UIColor clearColor]];
        [text setUserInteractionEnabled:NO];
        return text;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
    {
        return 0;
    }
    if (sectionIndex == 1) {
        return 32;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NavigationViewController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
    if (indexPath.section == 0 && indexPath.row == 0) { // 1
        NotesTableController *secondViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"notesTableController"];
        navigationController.viewControllers = @[secondViewController];
    }
    if (indexPath.section == 0 && indexPath.row == 1) { // 2
        AboutViewController *aboutViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"aboutController"];
        navigationController.viewControllers = @[aboutViewController];
    }
    if (indexPath.section == 0 && indexPath.row == 2) { // 3
        SettingsViewController *thirdViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"thirdController"];
        navigationController.viewControllers = @[thirdViewController];
    }
    /*
        if (indexPath.section == 0 && indexPath.row == 3) { // 4
        HelpViewController *helpViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"helpController"];
        navigationController.viewControllers = @[helpViewController];
    }
    */
    if (indexPath.section == 1) {
        DetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"detailController"];
        detail.rememberTitle = [NSString stringWithFormat:@"%@",_favorites[indexPath.row]];
        navigationController.viewControllers = @[detail];
    }
    
    self.frostedViewController.contentViewController = navigationController;
    [self.frostedViewController hideMenuViewController];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    MenuViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[MenuViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        _titles = @[@"Reminders", @"About", @"Settings"];//, @"Help"];
        _images = @[[UIImage imageNamed:@"Checklist"], [UIImage imageNamed:@"Info"], [UIImage imageNamed:@"Settings"]]; //, [UIImage imageNamed:@"FAQ"]
        cell.title.text = _titles[indexPath.row];
        cell.icon.image = _images[indexPath.row];
        
    }
    if (indexPath.section == 1) {
        cell.title.text = _favorites[indexPath.row];
        cell.icon.image = [UIImage imageNamed:@"Heart Thin"];
    }
    
    if (indexPath.section == 1) {
        NSMutableArray *leftUtilityButtons = [NSMutableArray new];
        
        [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.850 green:0.218 blue:0.159 alpha:0.750]
                                                    icon:[UIImage imageNamed:@"Thin Delete"]];
        cell.leftUtilityButtons = leftUtilityButtons;
        cell.delegate = self;
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch (index) {
        case 0:
        {
            [self readFileContents:@"Favorites"];
            [_favorites removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self writeFileContents:@"Favorites"];
            [self.tableView reloadData];
            break;
        }
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell; {
    return YES;
}

# pragma mark - Photo Management

- (void)selectPhoto {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"contactPhoto"];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    _imagePickerController.sourceType = sourceType;
    _imagePickerController.delegate = self;
    
    self.imagePickerController = _imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"MainPhoto"]];
    [self cancelActionSound];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.contactImage.image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self finishAndUpdate];
}

- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.imagePickerController = nil;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"MainPhoto"]];
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    NSURL *cDocuments = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents"]];
    NSString *imageName = [[cDocuments path] stringByAppendingPathComponent:[NSString stringWithFormat:@"MainPhoto.jpg"]];
    NSData *imageData = UIImageJPEGRepresentation(self.contactImage.image, 1.0);
    [imageData writeToFile:imageName atomically:YES];
    
    imageName = [[cDocuments path] stringByAppendingPathComponent:[NSString stringWithFormat:@"MainPhoto.jpg"]];
    self.contactImage.image = [UIImage imageWithContentsOfFile:imageName];
    [self photoCompleteSound];
}

- (void)loadPicture
{
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.solarpepper.Remember"];
    NSURL *cDocuments = [containerURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents"]];
    NSString *imageName = [[cDocuments path] stringByAppendingPathComponent:[NSString stringWithFormat:@"MainPhoto.jpg"]];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"contactPhoto"])
    { // Look out for the !
        self.contactImage.image = [UIImage imageNamed:@"Default Avatar"];
    } else {
        self.contactImage.image = [UIImage imageWithContentsOfFile:imageName];
    }
}

- (void)removePhoto
{
    self.contactImage.image = [UIImage imageNamed:@"Default Avatar"];
    [self finishAndUpdate];
}

#pragma mark - Audio Managment

- (void)menuOpeningSound {
    
    [_sound playSoundWithName:@"2" extension:@"caf"];
}

- (void)menuClosingSound {
    
    [_sound playSoundWithName:@"1" extension:@"caf"];
}

- (void)photoCompleteSound {
    
    [_sound playSoundWithName:@"5" extension:@"caf"];
}

- (void)cancelActionSound {
    
    [_sound playSoundWithName:@"1" extension:@"caf"];
}

#pragma mark - Date Management

- (void) updateDateLabel {
    //Updates the date label
    NSDate *pickerDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                    | NSCalendarUnitMonth
                                    | NSCalendarUnitHour
                                    | NSCalendarUnitMinute
                                    | NSCalendarUnitYear
                                               fromDate:pickerDate];
    NSInteger day = [components day];
    NSInteger month = [components month];
    NSInteger year = [components year];
    NSString *monthName;
    switch (month) {
        case 1:
            monthName = @"January";
            break;
            
        case 2:
            monthName = @"February";
            break;
            
        case 3:
            monthName = @"March";
            break;
            
        case 4:
            monthName = @"April";
            break;
            
        case 5:
            monthName = @"May";
            break;
            
        case 6:
            monthName = @"June";
            break;
            
        case 7:
            monthName = @"July";
            break;
            
        case 8:
            monthName = @"August";
            break;
            
        case 9:
            monthName = @"September";
            break;
            
        case 10:
            monthName = @"October";
            break;
            
        case 11:
            monthName = @"November";
            break;
            
        case 12:
            monthName = @"December";
            break;
            
        default:
            break;
    }
    
    // Returns value following format: September 10, 9:14 AM
    versionLabel.text = [NSString stringWithFormat:@"%@ %i, %i",monthName,(int)day, (int)year];
}

#pragma mark - Data Management

- (void)writeFileContents:(NSString *)name {
    /**
     Load plist path
     */
    [_dManager writeTableContentsFromArray:_favorites
                               containerID:@"group.com.solarpepper.Remember"
                                  fileName:name];
}

- (void)readFileContents:(NSString *)name {
    /**
     Load plist path
     */
    [_dManager readTableContentsFromContainerID:@"group.com.solarpepper.Remember"
                                       fileName:name];
    _favorites = _dManager.loadedTitles;
}

@end
