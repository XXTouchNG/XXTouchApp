//
//  XXScriptListTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXScriptListTableViewController.h"
#import <MJRefresh/MJRefresh.h>

static NSString * const kXXScriptListCellReuseIdentifier = @"kXXScriptListCellReuseIdentifier";

enum {
    kXXScriptListCellSection = 0,
};

@interface XXScriptListTableViewController ()
@property (nonatomic, strong) MJRefreshNormalHeader *refreshHeader;

@end

@implementation XXScriptListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"My Scripts", nil); // Override
    self.clearsSelectionOnViewWillAppear = YES; // Override
    
    self.tableView.scrollIndicatorInsets =
    self.tableView.contentInset =
    UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
    
    self.tableView.mj_header = self.refreshHeader;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - MJRefresh Header

- (MJRefreshNormalHeader *)refreshHeader {
    if (!_refreshHeader) {
        /* Init of MJRefresh */
        MJRefreshNormalHeader *normalHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadScriptListTableView)];
        [normalHeader setTitle:NSLocalizedString(@"Pull down", nil) forState:MJRefreshStateIdle];
        [normalHeader setTitle:NSLocalizedString(@"Release", nil) forState:MJRefreshStatePulling];
        [normalHeader setTitle:NSLocalizedString(@"Loading...", nil) forState:MJRefreshStateRefreshing];
        normalHeader.stateLabel.font = [UIFont systemFontOfSize:12.0];
        normalHeader.stateLabel.textColor = [UIColor lightGrayColor];
        normalHeader.lastUpdatedTimeLabel.hidden = YES;
        [normalHeader beginRefreshing];
        _refreshHeader = normalHeader;
    }
    return _refreshHeader;
}

- (void)reloadScriptListTableView {
    [self performSelector:@selector(endScriptListRefresh) withObject:nil afterDelay:1.0];
}

- (void)endScriptListRefresh {
    [self.refreshHeader endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kXXScriptListCellSection) {
        return 12;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kXXScriptListCellSection) {
        return 72;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kXXScriptListCellReuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

@end
