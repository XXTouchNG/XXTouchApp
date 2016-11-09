//
//  XXApplicationListTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/11/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXApplicationListTableViewController.h"
#import "XXApplicationDetailTableViewController.h"
#import "XXLocalDataService.h"
#import "XXLocalNetService.h"
#import "XXApplicationTableViewCell.h"
#import "XXCodeMakerService.h"
#include "NSString+AddSlashes.h"

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
@property (nonatomic, strong) NSArray *showData;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation XXApplicationListTableViewController {
    NSString *_previewString;
}

+ (NSString *)keyword {
    return @"@app@";
}

+ (NSString *)storyboardID {
    return kXXApplicationListTableViewControllerStoryboardID;
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
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchDisplayController.delegate = self;
    
    self.tableView.scrollIndicatorInsets =
    self.tableView.contentInset =
    UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
    
    [self fetchApplicationList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchApplicationList {
    @weakify(self);
    self.navigationController.view.userInteractionEnabled = NO;
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        NSError *err = nil;
        BOOL result = [XXLocalNetService localGetApplicationListWithError:&err];
        dispatch_async_on_main_queue(^{
            self.navigationController.view.userInteractionEnabled = YES;
            [self.navigationController.view hideToastActivity];
            if (!result) {
                [self.navigationController.view makeToast:[err localizedDescription]];
            } else {
                [self.tableView reloadData];
            }
        });
    });
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        if (section == kXXApplicationListCellSection) {
            return [[XXLocalDataService sharedInstance] bundles].count;
        }
    } else {
        return self.showData.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XXApplicationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kXXApplicationNameLabelReuseIdentifier forIndexPath:indexPath];
    if (tableView == self.tableView) {
        cell.appInfo = [[[XXLocalDataService sharedInstance] bundles] objectAtIndex:indexPath.row];
    } else {
        cell.appInfo = _showData[indexPath.row];
        return cell;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *identifier = nil;
    if (tableView == self.tableView) {
        identifier = [[XXLocalDataService sharedInstance] bundles][indexPath.row][kXXApplicationKeyBundleID];
    } else {
        identifier = _showData[indexPath.row][kXXApplicationKeyBundleID];
    }
    if (self.codeBlock) {
        identifier = [identifier addSlashes];
        _previewString = identifier;
        [self pushToNextControllerWithKeyword:[[self class] keyword] replacement:identifier];
    }
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
        predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", self.searchDisplayController.searchBar.text];
    } else if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == kXXApplicationSearchTypeBundleID) {
        predicate = [NSPredicate predicateWithFormat:@"bid CONTAINS[cd] %@", self.searchDisplayController.searchBar.text];
    }
    if (predicate) {
        self.showData = [[NSArray alloc] initWithArray:[[[XXLocalDataService sharedInstance] bundles] filteredArrayUsingPredicate:predicate]];
    }
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(XXApplicationTableViewCell *)sender {
    if (self.codeBlock) {
        return NO;
    }
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(XXApplicationTableViewCell *)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ((XXApplicationDetailTableViewController *)segue.destinationViewController).appInfo = [sender.appInfo copy];
}

#pragma mark - Previewing Bar

- (NSString *)previewString {
    return _previewString;
}

- (NSString *)subtitle {
    return NSLocalizedString(@"Select an application", nil);
}

#pragma mark - Memory

- (void)dealloc {
    CYLog(@"");
}

@end
