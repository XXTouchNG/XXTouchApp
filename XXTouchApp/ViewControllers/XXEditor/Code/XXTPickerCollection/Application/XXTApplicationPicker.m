//
// Created by Zheng on 02/05/2017.
// Copyright (c) 2017 Zheng. All rights reserved.
//

#include <objc/runtime.h>
#import "XXTApplicationPicker.h"
#import "XXTPickerHelper.h"
#import "LSApplicationProxy.h"
#import "XXTApplicationCell.h"
#import "XXTPickerNavigationController.h"
#import "XXTPickerDefine.h"

enum {
    kXXTApplicationPickerCellSection = 0,
};

enum {
    kXXTApplicationSearchTypeName = 0,
    kXXTApplicationSearchTypeBundleID
};

CFStringRef SBSCopyLocalizedApplicationNameForDisplayIdentifier(CFStringRef displayIdentifier);
CFDataRef SBSCopyIconImagePNGDataForDisplayIdentifier(CFStringRef displayIdentifier);

@interface XXTApplicationPicker ()
        <
        UITableViewDelegate,
        UITableViewDataSource,
        UISearchDisplayDelegate
        >
@property(nonatomic, strong) NSArray <NSDictionary *> *allApplications;
@property(nonatomic, strong) NSArray <NSDictionary *> *displayApplications;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSDictionary *selectedApplication;

@end

@implementation XXTApplicationPicker {
    XXTPickerTask *_pickerTask;
    NSString *_pickerSubtitle;
    UISearchDisplayController *_searchDisplayController;
}

@synthesize pickerTask = _pickerTask;

#pragma mark - XXTBasePicker

+ (NSString *)pickerKeyword {
    return @"@app@";
}

- (NSString *)pickerResult {
    return self.selectedApplication[@"applicationIdentifier"];
}

#pragma mark - Default Style

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.searchDisplayController.active) {
        return UIStatusBarStyleDefault;
    }
    return UIStatusBarStyleLightContent;
}

- (NSString *)title {
    return NSLocalizedStringFromTableInBundle(@"Application", nil, [XXTPickerHelper bundle], nil);
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;

    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    SEL selector = NSSelectorFromString(@"defaultWorkspace");
    NSObject *workspace = [LSApplicationWorkspace_class performSelector:selector];
    SEL selectorAll = NSSelectorFromString(@"allApplications");
    NSArray <LSApplicationProxy *> *allApplications = [workspace performSelector:selectorAll];
    
    NSString *whiteIconListPath = [[NSBundle mainBundle] pathForResource:@"xxt-white-icons" ofType:@"plist"];
    NSSet <NSString *> *blacklistApplications = [NSDictionary dictionaryWithContentsOfFile:whiteIconListPath][@"xxt-white-icons"];
    NSMutableArray <NSDictionary *> *filteredApplications = [NSMutableArray arrayWithCapacity:allApplications.count];
    for (LSApplicationProxy *appProxy in allApplications) {
        BOOL shouldAdd = YES;
        for (NSString *appId in blacklistApplications) {
            if ([appId isEqualToString:[appProxy applicationIdentifier]]) {
                shouldAdd = NO;
            }
        }
        if (shouldAdd) {
            NSString *applicationIdentifier = appProxy.applicationIdentifier;
            NSString *applicationBundle = [appProxy.resourcesDirectoryURL path];
            NSString *applicationContainer = nil;
            NSString *applicationLocalizedName = CFBridgingRelease(SBSCopyLocalizedApplicationNameForDisplayIdentifier((__bridge CFStringRef)(applicationIdentifier)));
            UIImage *applicationIconImage = [UIImage imageWithData:CFBridgingRelease(SBSCopyIconImagePNGDataForDisplayIdentifier((__bridge CFStringRef)(applicationIdentifier)))];
            if (XXTP_SYSTEM_8) {
                applicationContainer = [[appProxy dataContainerURL] path];
            } else {
                applicationContainer = [[appProxy containerURL] path];
            }
            if (applicationIdentifier && applicationBundle && applicationContainer && applicationLocalizedName && applicationIconImage) {
                [filteredApplications addObject:@{@"applicationIdentifier": applicationIdentifier, @"applicationBundle": applicationBundle, @"applicationContainer": applicationContainer, @"applicationLocalizedName": applicationLocalizedName, @"applicationIconImage": applicationIconImage}];
            }
        }
    }
    self.allApplications = filteredApplications;

    if (allApplications.count != 0) {
        self.selectedApplication = self.allApplications[0];
    }

    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [tableView registerNib:[UINib nibWithNibName:@"XXTApplicationCell" bundle:[XXTPickerHelper bundle]] forCellReuseIdentifier:kXXTApplicationCellReuseIdentifier];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    START_IGNORE_PARTIAL
    if (XXTP_SYSTEM_9) {
        tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }END_IGNORE_PARTIAL
    tableView.scrollIndicatorInsets = tableView.contentInset =
            UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
    [tableView setContentOffset:CGPointMake(0, self.searchDisplayController.searchBar.bounds.size.height)];
    [self.view addSubview:tableView];
    self.tableView = tableView;

    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44.f)];
    searchBar.placeholder = NSLocalizedStringFromTableInBundle(@"Search Application", nil, [XXTPickerHelper bundle], nil);
    searchBar.scopeButtonTitles = @[
            NSLocalizedStringFromTableInBundle(@"Name", nil, [XXTPickerHelper bundle], nil),
            NSLocalizedStringFromTableInBundle(@"Bundle ID", nil, [XXTPickerHelper bundle], nil)
    ];
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
    searchBar.backgroundColor = [UIColor whiteColor];
    searchBar.barTintColor = [UIColor whiteColor];
    searchBar.tintColor = [[XXTPickerHelper sharedInstance] frontColor];
    tableView.tableHeaderView = searchBar;

    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.delegate = self;
    _searchDisplayController = searchDisplayController;

    [self.pickerTask nextStep];
    UIBarButtonItem *rightItem = NULL;
    if ([self.pickerTask taskFinished]) {
        rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(taskFinished:)];
    } else {
        rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Next", nil, [XXTPickerHelper bundle], nil) style:UIBarButtonItemStylePlain target:self action:@selector(taskNextStep:)];
    }
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateSubtitle:NSLocalizedStringFromTableInBundle(@"Select an application.", nil, [XXTPickerHelper bundle], nil)];
}

#pragma mark - Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kXXTApplicationPickerCellSection) {
        return 66.f;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        if (section == kXXTApplicationPickerCellSection) {
            return self.allApplications.count;
        }
    } else {
        if (section == kXXTApplicationPickerCellSection) {
            return self.displayApplications.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XXTApplicationCell *cell = [tableView dequeueReusableCellWithIdentifier:kXXTApplicationCellReuseIdentifier];
    if (cell == nil) {
        cell = [[XXTApplicationCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:kXXTApplicationCellReuseIdentifier];
    }
    NSDictionary *applicationDetail = nil;
    if (tableView == self.tableView) {
        if (indexPath.section == kXXTApplicationPickerCellSection) {
            applicationDetail = self.allApplications[(NSUInteger) indexPath.row];
        }
    } else {
        if (indexPath.section == kXXTApplicationPickerCellSection) {
            applicationDetail = self.displayApplications[(NSUInteger) indexPath.row];
        }
    }
    [cell setApplicationName:applicationDetail[@"applicationLocalizedName"]];
    [cell setApplicationBundleID:applicationDetail[@"applicationIdentifier"]];
    [cell setApplicationIconImage:applicationDetail[@"applicationIconImage"]];
    [cell setTintColor:[[XXTPickerHelper sharedInstance] frontColor]];
    if (applicationDetail == self.selectedApplication) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *applicationDetail = nil;
    if (tableView == self.tableView) {
        if (indexPath.section == kXXTApplicationPickerCellSection) {
            applicationDetail = self.allApplications[(NSUInteger) indexPath.row];
        }
    } else {
        if (indexPath.section == kXXTApplicationPickerCellSection) {
            applicationDetail = self.displayApplications[(NSUInteger) indexPath.row];
        }
    }

    for (NSUInteger i = 0; i < tableView.visibleCells.count; ++i) {
        tableView.visibleCells[i].accessoryType = UITableViewCellAccessoryNone;
    }
    if (tableView != self.tableView) {
        for (NSUInteger i = 0; i < self.tableView.visibleCells.count; ++i) {
            if (self.allApplications[i] == applicationDetail) {
                self.tableView.visibleCells[i].accessoryType = UITableViewCellAccessoryCheckmark;
                [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:self.tableView.visibleCells[i]]
                                      atScrollPosition:UITableViewScrollPositionTop
                                              animated:NO];
            } else {
                self.tableView.visibleCells[i].accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }

    XXTApplicationCell *cell1 = [tableView cellForRowAtIndexPath:indexPath];
    cell1.accessoryType = UITableViewCellAccessoryCheckmark;
    self.selectedApplication = applicationDetail;

    [self updateSubtitle:[cell1 applicationBundleID]];
}

#pragma mark - Task Operations

- (void)taskFinished:(UIBarButtonItem *)sender {
    [[XXTPickerHelper sharedInstance] performFinished:self];
}

- (void)taskNextStep:(UIBarButtonItem *)sender {
    [[XXTPickerHelper sharedInstance] performNextStep:self];
}

- (void)updateSubtitle:(NSString *)subtitle {
    _pickerSubtitle = subtitle;
    [[XXTPickerHelper sharedInstance] performUpdateStep:self];
}

- (NSString *)pickerSubtitle {
    return _pickerSubtitle;
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [tableView registerNib:[UINib nibWithNibName:@"XXTApplicationCell" bundle:[XXTPickerHelper bundle]] forCellReuseIdentifier:kXXTApplicationCellReuseIdentifier];
    XXTPickerNavigationController *navController = ((XXTPickerNavigationController *)self.navigationController);
    [navController.popupBar setHidden:YES];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    XXTPickerNavigationController *navController = ((XXTPickerNavigationController *)self.navigationController);
    [navController.popupBar setHidden:NO];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {

}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self reloadSearch];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self reloadSearch];
    return YES;
}

- (void)reloadSearch {
    NSPredicate *predicate = nil;
    if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == kXXTApplicationSearchTypeName) {
        predicate = [NSPredicate predicateWithFormat:@"applicationLocalizedName CONTAINS[cd] %@", self.searchDisplayController.searchBar.text];
    } else if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == kXXTApplicationSearchTypeBundleID) {
        predicate = [NSPredicate predicateWithFormat:@"applicationIdentifier CONTAINS[cd] %@", self.searchDisplayController.searchBar.text];
    }
    if (predicate) {
        self.displayApplications = [[NSArray alloc] initWithArray:[self.allApplications filteredArrayUsingPredicate:predicate]];
    }
}

#pragma mark - Memory

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"[XXTApplicationPicker dealloc]");
#endif
}

@end
