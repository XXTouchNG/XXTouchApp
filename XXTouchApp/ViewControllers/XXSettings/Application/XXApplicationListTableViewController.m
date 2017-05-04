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

@interface XXApplicationListTableViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
UISearchDisplayDelegate
>
@property(nonatomic, strong) NSArray <LSApplicationProxy *> *allApplications;
@property(nonatomic, strong) NSArray <LSApplicationProxy *> *displayApplications;
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
    
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    SEL selector = NSSelectorFromString(@"defaultWorkspace");
    NSObject *workspace = [LSApplicationWorkspace_class performSelector:selector];
    SEL selectorAll = NSSelectorFromString(@"allApplications");
    NSArray <LSApplicationProxy *> *allApplications = [workspace performSelector:selectorAll];
    self.allApplications = allApplications;
    
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
    LSApplicationProxy *appProxy;
    if (tableView == self.tableView) {
        if (indexPath.section == kXXApplicationListCellSection) {
            appProxy = self.allApplications[(NSUInteger) indexPath.row];
        }
    } else {
        if (indexPath.section == kXXApplicationListCellSection) {
            appProxy = self.displayApplications[(NSUInteger) indexPath.row];
        }
    }
    [cell setApplicationName:[appProxy localizedName]];
    [cell setApplicationBundleID:[appProxy applicationIdentifier]];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        [cell setApplicationIconData:[appProxy performSelector:@selector(iconDataForVariant:) withObject:@(2)]];
    } else {
        [cell setApplicationIconData:[appProxy iconDataForVariant:0]];
    }
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
        predicate = [NSPredicate predicateWithFormat:@"localizedName CONTAINS[cd] %@", self.searchDisplayController.searchBar.text];
    } else if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == kXXApplicationSearchTypeBundleID) {
        predicate = [NSPredicate predicateWithFormat:@"applicationIdentifier CONTAINS[cd] %@", self.searchDisplayController.searchBar.text];
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
    LSApplicationProxy *appProxy;
    if (!self.searchDisplayController.active) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath.section == kXXApplicationListCellSection) {
            appProxy = self.allApplications[(NSUInteger) indexPath.row];
        }
    } else {
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:sender];
        if (indexPath.section == kXXApplicationListCellSection) {
            appProxy = self.displayApplications[(NSUInteger) indexPath.row];
        }
    }
    ((XXApplicationDetailTableViewController *)segue.destinationViewController).appProxy = appProxy;
}

#pragma mark - Memory

- (void)dealloc {
    XXLog(@"");
}

@end
