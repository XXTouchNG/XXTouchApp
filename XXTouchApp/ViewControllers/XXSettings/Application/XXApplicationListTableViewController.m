//
//  XXApplicationListTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/11/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#include <objc/runtime.h>
#import "XXApplicationListTableViewController.h"
#import "XXApplicationDetailTableViewController.h"
#import "XXLocalDataService.h"
#import "XXLocalNetService.h"
#import "XXApplicationTableViewCell.h"
#import "NSString+AddSlashes.h"
#import "LSApplicationProxy.h"

static NSString * const kXXApplicationNameLabelReuseIdentifier = @"kXXApplicationNameLabelReuseIdentifier";

enum {
    kXXApplicationListCellSection = 0,
};

enum {
    kXXApplicationSearchTypeName = 0,
    kXXApplicationSearchTypeBundleID
};

#if TARGET_IPHONE_SIMULATOR

CFStringRef SBSCopyLocalizedApplicationNameForDisplayIdentifier(CFStringRef displayIdentifier) {
    return CFBridgingRetain(@"");
}

CFDataRef SBSCopyIconImagePNGDataForDisplayIdentifier(CFStringRef displayIdentifier) {
    return CFBridgingRetain([[NSData alloc] init]);
}

#else

CFArrayRef SBSCopyApplicationDisplayIdentifiers(bool onlyActive, bool debuggable);
CFStringRef SBSCopyLocalizedApplicationNameForDisplayIdentifier(CFStringRef displayIdentifier);
CFDataRef SBSCopyIconImagePNGDataForDisplayIdentifier(CFStringRef displayIdentifier);

#endif

@interface XXApplicationListTableViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
UISearchDisplayDelegate
>
@property(nonatomic, strong) NSArray <NSDictionary *> *allApplications;
@property(nonatomic, strong) NSArray <NSDictionary *> *displayApplications;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation XXApplicationListTableViewController {
    NSString *_previewString;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.searchDisplayController.active) {
        return UIStatusBarStyleDefault;
    }
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _previewString = nil;
    self.title = NSLocalizedString(@"Application List", nil);
    
    self.allApplications = ({
        NSArray <NSString *> *applicationIdentifiers = (NSArray *)CFBridgingRelease(SBSCopyApplicationDisplayIdentifiers(false, false));
        NSMutableArray <LSApplicationProxy *> *allApplications = nil;
        if (applicationIdentifiers) {
            allApplications = [NSMutableArray arrayWithCapacity:applicationIdentifiers.count];
            [applicationIdentifiers enumerateObjectsUsingBlock:^(NSString * _Nonnull bid, NSUInteger idx, BOOL * _Nonnull stop) {
                LSApplicationProxy *proxy = [LSApplicationProxy applicationProxyForIdentifier:bid];
                [allApplications addObject:proxy];
            }];
        } else {
            SEL selectorAll = NSSelectorFromString(@"allApplications");
            Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
            SEL selector = NSSelectorFromString(@"defaultWorkspace");
            id applicationWorkspace = [LSApplicationWorkspace_class performSelector:selector];
            allApplications = [applicationWorkspace performSelector:selectorAll];
        }
        NSString *whiteIconListPath = [[NSBundle mainBundle] pathForResource:@"xxte-white-icons" ofType:@"plist"];
        NSSet <NSString *> *blacklistApplications = [NSDictionary dictionaryWithContentsOfFile:whiteIconListPath][@"xxte-white-icons"];
        NSMutableArray <NSDictionary *> *filteredApplications = [NSMutableArray arrayWithCapacity:allApplications.count];
        for (LSApplicationProxy *appProxy in allApplications) {
            NSString *applicationBundleID = appProxy.applicationIdentifier;
            BOOL shouldAdd = ![blacklistApplications containsObject:applicationBundleID];
            if (shouldAdd) {
                NSString *applicationBundlePath = [appProxy.resourcesDirectoryURL path];
                NSString *applicationContainerPath = nil;
                NSString *applicationName = CFBridgingRelease(SBSCopyLocalizedApplicationNameForDisplayIdentifier((__bridge CFStringRef)(applicationBundleID)));
                if (!applicationName) {
                    applicationName = appProxy.localizedName;
                }
                UIImage *applicationIconImage = [UIImage imageWithData:CFBridgingRelease(SBSCopyIconImagePNGDataForDisplayIdentifier((__bridge CFStringRef)(applicationBundleID)))];
                if (XXT_SYSTEM_8) {
                    if ([appProxy respondsToSelector:@selector(dataContainerURL)]) {
                        applicationContainerPath = [[appProxy dataContainerURL] path];
                    }
                } else {
                    if ([appProxy respondsToSelector:@selector(containerURL)]) {
                        applicationContainerPath = [[appProxy containerURL] path];
                    }
                }
                NSMutableDictionary *applicationDetail = [[NSMutableDictionary alloc] init];
                if (applicationBundleID) {
                    applicationDetail[kXXTMoreApplicationDetailKeyBundleID] = applicationBundleID;
                }
                if (applicationName) {
                    applicationDetail[kXXTMoreApplicationDetailKeyName] = applicationName;
                }
                if (applicationBundlePath) {
                    applicationDetail[kXXTMoreApplicationDetailKeyBundlePath] = applicationBundlePath;
                }
                if (applicationContainerPath) {
                    applicationDetail[kXXTMoreApplicationDetailKeyContainerPath] = applicationContainerPath;
                }
                if (applicationIconImage) {
                    applicationDetail[kXXTMoreApplicationDetailKeyIconImage] = applicationIconImage;
                }
                [filteredApplications addObject:[applicationDetail copy]];
            }
        }
        filteredApplications;
    });;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchDisplayController.delegate = self;
    
    self.tableView.scrollIndicatorInsets =
    self.tableView.contentInset =
    UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
    
    [self.tableView setContentOffset:CGPointMake(0, self.searchDisplayController.searchBar.bounds.size.height)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kXXApplicationListCellSection) {
        return 66.f;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        if (section == kXXApplicationListCellSection) {
            return self.allApplications.count;
        }
    } else {
        if (section == kXXApplicationListCellSection) {
            return self.displayApplications.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XXApplicationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kXXApplicationNameLabelReuseIdentifier forIndexPath:indexPath];
    NSDictionary *applicationDetail = nil;
    if (tableView == self.tableView) {
        if (indexPath.section == kXXApplicationListCellSection) {
            applicationDetail = self.allApplications[(NSUInteger) indexPath.row];
        }
    } else {
        if (indexPath.section == kXXApplicationListCellSection) {
            applicationDetail = self.displayApplications[(NSUInteger) indexPath.row];
        }
    }
    [cell setApplicationName:applicationDetail[kXXTMoreApplicationDetailKeyName]];
    [cell setApplicationBundleID:applicationDetail[kXXTMoreApplicationDetailKeyBundleID]];
    [cell setApplicationIconImage:applicationDetail[kXXTMoreApplicationDetailKeyIconImage]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UISearchDisplayDelegate

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
    if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == kXXApplicationSearchTypeName) {
        predicate = [NSPredicate predicateWithFormat:@"kXXTMoreApplicationDetailKeyName CONTAINS[cd] %@", self.searchDisplayController.searchBar.text];
    } else if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == kXXApplicationSearchTypeBundleID) {
        predicate = [NSPredicate predicateWithFormat:@"kXXTMoreApplicationDetailKeyBundleID CONTAINS[cd] %@", self.searchDisplayController.searchBar.text];
    }
    if (predicate) {
        self.displayApplications = [[NSArray alloc] initWithArray:[self.allApplications filteredArrayUsingPredicate:predicate]];
    }
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(XXApplicationTableViewCell *)sender {
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(XXApplicationTableViewCell *)sender {
    NSDictionary *applicationDetail = nil;
    if (!self.searchDisplayController.active) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath.section == kXXApplicationListCellSection) {
            applicationDetail = self.allApplications[(NSUInteger) indexPath.row];
        }
    } else {
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:sender];
        if (indexPath.section == kXXApplicationListCellSection) {
            applicationDetail = self.displayApplications[(NSUInteger) indexPath.row];
        }
    }
    
    ((XXApplicationDetailTableViewController *)segue.destinationViewController).applicationDetail = applicationDetail;
}

#pragma mark - Memory

- (void)dealloc {
    XXLog(@"");
}

@end
