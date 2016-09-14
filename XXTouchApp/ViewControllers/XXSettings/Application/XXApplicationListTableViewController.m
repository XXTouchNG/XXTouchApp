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
#import <MJRefresh/MJRefresh.h>

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
UITableViewDataSource
>
@property (nonatomic, strong) MJRefreshNormalHeader *refreshHeader;
@property (nonatomic, strong) NSArray *showData;

@end

@implementation XXApplicationListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.scrollIndicatorInsets =
    self.tableView.contentInset =
    UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
    
    self.tableView.mj_header = self.refreshHeader;
    
    if ([[XXLocalDataService sharedInstance] bundles].count == 0) {
        [self.refreshHeader beginRefreshing];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MJRefresh Header

- (MJRefreshNormalHeader *)refreshHeader {
    if (!_refreshHeader) {
        MJRefreshNormalHeader *normalHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(startMJRefreshing)];
        [normalHeader setTitle:XXLString(@"Pull down") forState:MJRefreshStateIdle];
        [normalHeader setTitle:XXLString(@"Release") forState:MJRefreshStatePulling];
        [normalHeader setTitle:XXLString(@"Loading...") forState:MJRefreshStateRefreshing];
        normalHeader.stateLabel.font = [UIFont systemFontOfSize:12.0];
        normalHeader.stateLabel.textColor = [UIColor lightGrayColor];
        normalHeader.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightThin];
        normalHeader.lastUpdatedTimeLabel.textColor = [UIColor lightGrayColor];
        _refreshHeader = normalHeader;
    }
    return _refreshHeader;
}

- (void)startMJRefreshing {
    [self fetchApplicationList];
}

- (void)fetchApplicationList {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        NSError *err = nil;
        BOOL result = [XXLocalNetService localGetApplicationListWithError:&err];
        dispatch_async_on_main_queue(^{
            [self endMJRefreshing];
            if (!result) {
                [self.navigationController.view makeToast:[err localizedDescription]];
            } else {
                [self.tableView reloadData];
            }
        });
    });
}

- (void)endMJRefreshing {
    if ([self.refreshHeader isRefreshing]) {
        [self.refreshHeader endRefreshing];
    }
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
        NSPredicate *predicate = nil;
        if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == kXXApplicationSearchTypeName) {
            predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", self.searchDisplayController.searchBar.text];
        } else if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == kXXApplicationSearchTypeBundleID) {
            predicate = [NSPredicate predicateWithFormat:@"bid CONTAINS[cd] %@", self.searchDisplayController.searchBar.text];
        }
        self.showData = [[NSArray alloc] initWithArray:[[[XXLocalDataService sharedInstance] bundles] filteredArrayUsingPredicate:predicate]];
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
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(XXApplicationTableViewCell *)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ((XXApplicationDetailTableViewController *)segue.destinationViewController).appInfo = [sender.appInfo copy];
}

- (void)dealloc {
    CYLog(@"");
}

@end
