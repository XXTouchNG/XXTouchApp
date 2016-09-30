//
//  MBPlacePickerController.m
//  MBPlacePickerController
//
//  Created by Moshe on 6/23/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//


#import "MBPlacePickerController.h"
#import "MBMapView.h"

#import "MBLocationManager.h"

@import CoreLocation;
@import MapKit;

/**
 *  A key used to persist the last location.
 */

static NSString *kLocationPersistenceKey = @"com.mosheberman.location-persist-key";

/**
 *
 */

@interface MBPlacePickerController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, UISearchBarDelegate>

/**
 *  An array of location dictionaries.
 */

@property (nonatomic, strong) NSArray *unsortedLocationList;

/**
 *  A dictionary of dictionaries, sorted by continent.
 */

@property (nonatomic, strong) NSDictionary *locationsByContinent;

/**
 *  A table to display a list of locations.
 */

@property (nonatomic, strong) UITableView *tableView;

/**
 *  A flag to determine if we're using the user's location or not.
 */

@property (nonatomic, assign) BOOL automaticUpdates;

/**
 *  A navigation controller to present inside of.
 */
@property (nonatomic, strong) UINavigationController *navigationController;

/**
 *  A search bar.
 */

@property (nonatomic, strong) UISearchBar *searchBar;

/**
 *  Track the previous indexPath to properly deselect it.
 */

@property (nonatomic, strong) NSIndexPath *previousIndexPath;

@end

@implementation MBPlacePickerController

/**
 *  @return A singleton instance of MBPlacePickerController.
 */

+ (instancetype)sharedPicker
{
    static MBPlacePickerController *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MBPlacePickerController alloc] init];
    });
    
    return manager;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Designated initializer

/**
 *  Designated initializer
 */

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        /**
         *  UI
         */
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _map = [[MBMapView alloc] init];
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];    //  We'll resize in loadView
        
        /**
         *  Model and data.
         */
        
        _unsortedLocationList = @[];
        _locationsByContinent = @{};
        _previousIndexPath = nil;

        _serverURL = @"";
        
        //  A nil value will cause the NSUserDefaults API to fall back to standardUserDefaults.
        _defaultsSuiteName = nil;
        
        /**
         *  Flags
         */
        
        _sortByContinent = YES;
        _automaticUpdates = NO;
        _showSearch = YES;
        _transient = YES;
        
        /**
         *  Load the cached location.
         */

        NSUserDefaults *extensionFriendlyDefaults = [[NSUserDefaults alloc] initWithSuiteName:self.defaultsSuiteName];
        NSDictionary *previouslySavedDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kLocationPersistenceKey];
        
        /**
         *  Check if the key exists in the legacy user defaults location, pre-extensions.
         *  If it doesn't exist in the new defaults store, but it's in the old store, copy it over.
         */
        
        if (![extensionFriendlyDefaults dictionaryForKey:kLocationPersistenceKey] && previouslySavedDictionary)
        {
            [extensionFriendlyDefaults setObject:previouslySavedDictionary forKey:kLocationPersistenceKey];
            [extensionFriendlyDefaults synchronize];
        }
        
        NSDictionary *previousLocationData = [extensionFriendlyDefaults dictionaryForKey:kLocationPersistenceKey];
        
        CGFloat lat = [previousLocationData[@"latitude"] floatValue];
        CGFloat lon = [previousLocationData[@"longitude"] floatValue];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        
        _location = location;
    
    }
    
    return self;
}

- (void)loadView
{
    /**
     *  Create the view.
     */
    
    CGRect bounds = [UIApplication sharedApplication].keyWindow.rootViewController.view.bounds;
    
    self.view = [[UIView alloc] initWithFrame:bounds];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    /**
     *  Configure a map.
     */
    
    self.map.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;;
    CGRect mapFrame = self.map.frame;
    mapFrame.origin.y = [self.topLayoutGuide length];
    mapFrame.origin.x = CGRectGetMidX(self.view.bounds) - CGRectGetMidX(mapFrame);
    self.map.frame = mapFrame;
    [self.view addSubview:self.map];
    
    /**
     *  Configure a table.
     */
    
    CGRect tableBounds = CGRectMake(0, CGRectGetMaxY(self.map.frame), CGRectGetWidth(bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.map.frame));
    ;
    self.tableView.frame = tableBounds;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.tableView];
    
    /**
     *  Make the title match the tint color.
     */
    
    UIColor *color = [UIApplication sharedApplication].keyWindow.tintColor;
    
    if(color)
    {
        NSDictionary *attributes = @{NSForegroundColorAttributeName : color};
        self.navigationController.navigationBar.titleTextAttributes = attributes;
    }
}

#pragma mark - View Lifecycle

/** ---
 *  @name View Lifecycle
 *  ---
 */

/**
 *  Calls the vanilla viewDidLoad then does a ton of loading itself...
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /**
     *  Load up locations.
     */
    
    [self loadLocationsFromDisk];
    
    /**
     *   Add a  button for automatic location updates.
     */
    
    UIBarButtonItem *autolocateButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Automatic", @"A title for automatic location updates") style:UIBarButtonItemStylePlain target:self action:@selector(enableAutomaticUpdates)];
    
    self.navigationItem.rightBarButtonItem = autolocateButton;
    
    /**
     *  Set a background color.
     */
    
    self.view.backgroundColor = [UIColor colorWithRed:0.05 green:0.01 blue:0.20 alpha:1.00];
    
    /**
     *  Register a table view cell class.
     */
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    /**
     *  Prepare some localized strings for the search bar.
     */
    
    NSString *searchPlaceholder = NSLocalizedString(@"Search", @"A placeholder for the search bar.");

    /**
     *  Wire up the search bar.
     */
    
    self.searchBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44.0f);
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.placeholder = searchPlaceholder;
    
    /**
     *  If search is enabled, add the search bar to the view hierarchy.
     */
    
    if (self.showSearch)
    {
        self.tableView.tableHeaderView = self.searchBar;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /**
     *  Highlight the coordinate in the place picker if there was one.
     */
    
    if (self.location != nil)
    {
        [[self map] markCoordinate:[self location].coordinate];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.previousIndexPath = nil;
    [self refreshLocationsFromServer];
    
    if(!self.automaticUpdates)
    {
        [self.map markCoordinate:self.location.coordinate];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.transient) {
        [self _clearSearchState];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Presenting and Dismissing the Picker

/** ---
 *  @name Presenting and Dismissing the Picker
 *  ---
 */

/**
 * Calls displayInViewController: passing the root view controller of the application's keyWindow.
 */

- (void)display
{
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;

    [self displayInViewController:viewController];
}

/**
 *  Displays the place picker in the appropriate view controller.
 *
 *  @discussion If the viewController is a navigationController, we'll push onto the stack.
 *  Otherwise, the place picker will wrap itself in a UINavigationController and present itself modally.
 *
 *  @param viewController A view controller to display in.
 *
 */

- (void)displayInViewController:(UIViewController *)viewController
{
    
    /**
     *  First, nil out the navigation controller, in case.
     */
    
    self.navigationController = nil;
    

    /**
     *  If the target view controller is a navigation controller, push the VC onto the stack.
     */
    
    if ([viewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *vc = (UINavigationController *)viewController;
        [vc pushViewController:self animated:YES];
    }
    
    /**
     *  ...else, present the parent navigation controller controller.
     */
    
    else
    {
        /**
         *  Wrap in our own navigation controller...
         */
        
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:self];
        
        /**
         *  Add a "Done" button.
         */
        
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
        
        if (self.transient)
        {
            button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
        }
        
        self.navigationItem.leftBarButtonItem = button;
         
        /**
         *  On iPad, change the modal presentation style.
         */
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [self.navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
        }
        
        /**
         *  Present the navigation controller.
         */
        
        [viewController presentViewController:self.navigationController animated:YES completion:nil];
    }
}

/**
 *  Asks the parent VC to dismiss self.
 */

- (void)dismiss
{
    /**
     *  If the navigation controller is presented, dismiss the navigation controller.
     */
    
    if(self.navigationController.presentingViewController)
    {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    /**
     *  Otherwise, pop to the next view controller on the stack.
     */
    
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    /**
     *  Tell the delegate that the location picker is finished.
     */
    
    if([self.delegate respondsToSelector:@selector(placePickerControllerDidFinish:)])
    {
        [self.delegate placePickerControllerDidFinish:self];
    }
}

#pragma mark - Automatic Location Updates

/** ---
 *  @name Automatic Location Updates
 *  ---
 */

/**
 *  This method automatically updates the
 *  location and calls the delegate when
 *  there are changes to report.
 */

- (void)enableAutomaticUpdates
{
    /**
     *  Call the delegate method.
     */
    
    if ([self.delegate respondsToSelector:@selector(placePickerControllerDidTapAutomaticButton:)])
    {
        [self.delegate placePickerControllerDidTapAutomaticButton:self];
    }
    
    /**
     *  Check authorization.
     */
    
    if ([[MBLocationManager sharedManager] authorizationDenied])
    {
        NSString *message = NSLocalizedString(@"Please allow location access in Settings.", @"A message for an error alert.");
        self.navigationItem.prompt = message;
    }
    else if([[MBLocationManager sharedManager] authorizationRestricted])
    {
        NSString *message = NSLocalizedString(@"Restricted enabled, disable them in Settings.", @"A message for an error alert.");
        self.navigationItem.prompt = message;
    }
    
    /**
     *  Don't enable twice in a row.
     */
    
    if (self.automaticUpdates)
    {
        return;
    }
    
    /**
     *  Set the flag.
     */
    
    self.automaticUpdates = YES;
    
    /**
     *  Trigger automatic location updates.
     */
    
    [[MBLocationManager sharedManager] updateLocationWithCompletionHandler:^(NSArray *locations, CLHeading *heading, CLAuthorizationStatus authorizationStatus) {
        
        /**
         *  On each update, pull the location.
         */
        
        CLLocation *lastLocation = [[MBLocationManager sharedManager] location];
        
        /**
         *  If there's a location...
         */
        if (lastLocation)
        {
            /**
             *  ...assign the location...
             */
            self.location = lastLocation;
            
            /**
             *  Reload the table so we don't have an extra checkmark.
             */
            
            [[self tableView] reloadData];
            
            /**
             *  ...display it...
             */
            [self.map setShowUserLocation:YES];
            [self.map markCoordinate:lastLocation.coordinate];
            
            /**
             *  ...and attempt to call the delegate.
             */
            
            id<MBPlacePickerDelegate> delegate = self.delegate;
            
            if ([delegate respondsToSelector:@selector(placePickerController:didChangeToPlace:)])
            {
                [delegate placePickerController:self didChangeToPlace:lastLocation];
                
                if(self.transient)
                {
                    [self dismiss];
                }
            }
        }
    }];
}

/**
 *  Stops the automatic updates.
 *
 *  Called whenever the user chooses a location from the list.
 */

- (void)disableAutomaticUpdates
{
    self.automaticUpdates = NO;
    [[MBLocationManager sharedManager] stopUpdatingLocation];
}

#pragma mark - UITableViewDataSource

/** ---
 *  @name UITableView Data Source
 *  ---
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    //  Pull out the location
    NSDictionary *location =  [self _locationForIndexPath:indexPath];
    
    cell.textLabel.text = location[@"name"];
    
    /**
     *  Compare the display cell's backing location to the currently selected one.
     */
    
    CGFloat lat = [location[@"latitude"] floatValue];
    CGFloat lon = [location [@"longitude"] floatValue];
    
    CGFloat storedLat = self.location.coordinate.latitude;
    CGFloat storedLon = self.location.coordinate.longitude;
    
    if (lat == storedLat && lon == storedLon)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

/**
 *  Return enough rows for the continent, or for all unsorted locations.
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CGFloat count = 0;
    
    if (self.sortByContinent == YES)
    {
        NSString *continentKeyForSection = [self _sortedContinentNames][section];
        count = [self.locationsByContinent[continentKeyForSection] count];
    }
    else{
        count = [[self _searchedUnsortedLocations] count];
    }
    
    return count;
}

/**
 *  Return enough sections for each continent.
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.sortByContinent == YES)
    {
        return self.locationsByContinent.allKeys.count;
    }
    return 1;
}

/**
 *  @param tableView The table view.
 *  @param section A section.
 *
 *  @return The string "Unsorted" if alphabetical, otherwise the name of a continent.
 */

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"Unsorted";
    
    if (self.sortByContinent == YES)
    {
        title = [self _sortedContinentNames][section];
    }
    
    return title;
}

#pragma mark - UITableViewDelegate

/** ---
 *  @name UITableViewDelegate
 *  ---
 */

/**
 *  Handle cell selection.
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /**
     *  Disable automatic updates.
     */
    
    [self disableAutomaticUpdates];
    
    /**
     *  Pull out a location from the list.
     */
    
    NSDictionary *location = [self _locationForIndexPath:indexPath];
    
    /**
     *  Extract the location from the tapped location.
     */
    
    CLLocationDegrees latitude = [location[@"latitude"] floatValue];
    CLLocationDegrees longitude = [location[@"longitude"] floatValue];
    
    /**
     *  Store it as a CLLocation in the location picker.
     */
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    CLLocation *place = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    /**
     *  Assign the location to the picker.
     */
    
    self.location = place;
    
    /**
     *  Update the map.
     */
    
    [self.map markCoordinate:coordinate];
    
    /**
     *  Call the delegate method with the place.
     */
    
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(placePickerController:didChangeToPlace:)]) {
        [[self delegate] placePickerController:self didChangeToPlace:place];
        [self dismiss];
    }
    
    /**
     *  Update the list.
     */
    
    if (self.previousIndexPath && ! [indexPath isEqual:self.previousIndexPath])
    {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath, self.previousIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    self.previousIndexPath = indexPath;
}

#pragma mark - Location Access

- (NSDictionary *)_locationForIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *locations = [self _searchedUnsortedLocations];
    
    /**
     *  Now pull out the appropriate location.
     */
    
    NSDictionary *location = nil;
    
    if (self.sortByContinent)
    {
        //  Gets the name of the continent.
        NSString *continent = [self _sortedContinentNames][indexPath.section];
        
        //  Gets all the locations in the continent
        NSArray *locationsForContinent = [self locationsByContinent][continent];
        
        //  Gets a specific location from the continent.
        NSInteger row = indexPath.row;
        
        if (row < locationsForContinent.count)
        {
            location = locationsForContinent[row];
        }
    }
    else
    {
        location = locations[indexPath.row];
    }
    
    
    return location;
}

#pragma mark - Location List

/**
 *  Updates the location data from the server, then reloads the tableview.
 */

- (void)refreshLocationsFromServer
{
    /**
     *  Download a updated location list.
     */
    
    NSURL *url = [NSURL URLWithString:self.serverURL];
    
    if (url)
    {
        
        NSURLSessionDataTask *dataTask = [NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (data)
            {
                NSError *error = nil;
                NSArray *locations = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                
                if (error && ! locations)
                {
                    NSLog(@"MBPlacePicker (CRLCoreLib): Failed to unwrap fresh location list.");
                }
                else if (locations)
                {
                    if (!locations.count) {
                        NSLog(@"MBPlacePicker (CRLCoreLib): Recieved an empty list of locations.");
                    }
                    else
                    {
                        NSString *path = self.filePath;

                        [data writeToFile:path atomically:YES];
                        
                        [self setUnsortedLocationList:locations];
                        
                        //  TODO: Ensure existing location is in list, if not, add it.
                        [[self tableView] reloadData];
                    }
                }
            }
            else{
                NSLog(@"MBPlacePicker : Failed to download fresh location list.");
            }
        }];
        
        [dataTask resume];
    }
    else
    {
        NSLog(@"Failed to update locations from server. Invalid URL.");
    }
}


/**
 *  Loads the locations from the app bundle.
 */

- (void)loadLocationsFromDisk
{
    
    NSString *applicationString = self.filePath;
    NSString *locationsPath = [applicationString stringByAppendingString:@"/locations.json"];
    NSData *localData = [[NSData alloc] initWithContentsOfFile:locationsPath];
    
    NSError *error = nil;
    
    if (!localData)
    {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"locations" ofType:@"json"];
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        
        
        if (data) {
            NSArray *locations = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            
            self.unsortedLocationList = locations;
        }
        else
        {
            NSLog(@"Data load failed.");
        }
    }
    else
    {
        NSArray *locations = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingMutableContainers error:&error];
        
        self.unsortedLocationList = locations;
    }
}

/**
 *
 */

- (NSString *)filePath
{
    return [NSFileManager.defaultManager URLsForDirectory:NSLibraryDirectory inDomains:NSAllDomainsMask].firstObject.path;
}

/**
 *  Searches the location list and returns an array of 
 *  locations matching eithe rname or the continent.
 */

- (NSArray *)_searchedUnsortedLocations
{
    //  Take the search term
    __block NSString *searchTerm = self.searchBar.text;
    
    //  Take the unsorted list.
    __block NSArray *locations = self.unsortedLocationList;
    
    if (searchTerm != nil && searchTerm.length > 0)
    {
        NSPredicate *searchPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {

            NSDictionary *location = evaluatedObject;
            
            NSString *name = location[@"name"];
            NSString *continent = location[@"continent"];
            
            BOOL continentMatch = NO;
            BOOL nameMatch = NO;
            
            if ([name rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                nameMatch = YES;
            }
            else if ([continent rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                continentMatch = YES;
            }
            
            return (nameMatch || continentMatch);
        }];
        
        locations = [locations filteredArrayUsingPredicate:searchPredicate];
    }
    else
    {
        //  There's no search term.
    }
    
    return locations;
}

/**
 *  Converts an array of locations to a dictionary of locations sorted by continent.
 */

- (void)_sortArrayOfLocationsByContinent
{
    NSMutableDictionary *continents = [[NSMutableDictionary alloc] init];
    
    /**
     *  First pull out original locations and apply search term.
     */
    
    NSArray *originalLocations = [self _searchedUnsortedLocations];
    
    for (NSDictionary *location in originalLocations)
    {
        NSString *continent = location[@"continent"];
        
        /**
         *  If there's no continent, skip the location.
         */
        
        if (!continent)
        {
            continue;
        }
        
        /**
         *  Ensure we have an array for the location.
         */
        
        if (!continents[continent]) {
            continents[continent] = [[NSMutableArray alloc] init];
        }
        
        /**
         *  Add the location.
         */
        
        [continents[continent] addObject:location];
    }
    
    self.locationsByContinent = continents;
}

#pragma mark - Accessing Sorted Locations

/** ---
 *  @name Accessing Sorted Locations
 *  ---
 */
/**
 *  @return The continents, sorted by name.
 */

- (NSArray *)_sortedContinentNames
{
    return [self.locationsByContinent.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

#pragma mark - Custom Setters

/** ---
 *  @name Custom Setters
 *  ---
 */

/**
 *  Sets the array of locations, then creates a sorted copy of the same locations, by continent.
 *
 *  @param locations An array of dictionaries describing locations.
 */

- (void)setUnsortedLocationList:(NSArray *)locations
{
    if (locations)
    {
        _unsortedLocationList = locations;
        [self _sortArrayOfLocationsByContinent];    //  Sort by continent.
    }
}

/**
 *  @param sortByContinent A parameter to toggle the sort order of the locations.
 */

- (void)setSortByContinent:(BOOL)sortByContinent
{
    _sortByContinent = sortByContinent;
    
    if (sortByContinent)
    {
        [self _sortArrayOfLocationsByContinent];
    }
    
    [[self tableView] reloadData];
}

/**
 *  Sets the current location and update the map.
 *  Setting this property does not call the delegate.
 *
 *  @param location The location to display.
 */

- (void)setLocation:(CLLocation *)location
{
    _location = location;
    
    if (location)
    {
        [self.map markCoordinate:location.coordinate];
        
        NSDictionary *newLocationData = @{@"latitude": @(location.coordinate.latitude), @"longitude" : @(location.coordinate.longitude)};
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:self.defaultsSuiteName];
        [defaults setObject:newLocationData forKey:kLocationPersistenceKey];
        [defaults synchronize];
    }
}

/**
 *  Toggles the search bar.
 */

- (void)setShowSearch:(BOOL)showSearch
{
    _showSearch = showSearch;
    
    if (_showSearch)
    {
        self.tableView.tableHeaderView = self.searchBar;
    }
    else
    {
        self.tableView.tableHeaderView = nil;
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

/**
 *  Execute a search when the search term changes.
 */

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //  This causes the cell to regenerate a new cache of sorted-by-continent locations.
    self.unsortedLocationList = self.unsortedLocationList;
    
    //  Reload the table view, of course.
    [[self tableView] reloadData];
}

/**
 *  Toggle the search controls when the search appears.
 */
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

/**
 *  Toggle the search controls when the search ends.
 */

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}

/**
 *  When the user taps "search" on the keyboard.
 */

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - Clear Search State

/** ---
 *  @name Clear Search State
 *  ---
 */


/**
 *  This method empties the search bar, 
 *  resets the data source, and causes
 *  the table to reload.
 */

- (void)_clearSearchState
{
    self.searchBar.text = nil;
    self.unsortedLocationList = self.unsortedLocationList;
    [self.tableView reloadData];
}

#pragma mark - Accuracy

- (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy
{
    [[MBLocationManager sharedManager] setDesiredAccuracy:desiredAccuracy];
}

- (CLLocationAccuracy)desiredAccuracy
{
    return [[MBLocationManager sharedManager] desiredAccuracy];
}

@end
