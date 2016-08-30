//
//  XXScriptListTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXSwipeableCell.h"
#import "XXScriptListTableViewController.h"
#import <MJRefresh/MJRefresh.h>

static NSString * const kXXScriptListCellReuseIdentifier = @"kXXScriptListCellReuseIdentifier";

enum {
    kXXScriptListCellSection = 0,
};

@interface XXScriptListTableViewController () <UITableViewDelegate>
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) MJRefreshNormalHeader *refreshHeader;

@end

@implementation XXScriptListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromTable(@"My Scripts", @"XXTouch", nil); // Override
    self.clearsSelectionOnViewWillAppear = YES; // Override
    
    self.tableView.delegate = self;
    
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
        [normalHeader setTitle:NSLocalizedStringFromTable(@"Pull down", @"XXTouch", nil) forState:MJRefreshStateIdle];
        [normalHeader setTitle:NSLocalizedStringFromTable(@"Release", @"XXTouch", nil) forState:MJRefreshStatePulling];
        [normalHeader setTitle:NSLocalizedStringFromTable(@"Loading...", @"XXTouch", nil) forState:MJRefreshStateRefreshing];
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
    XXSwipeableCell *cell = [tableView dequeueReusableCellWithIdentifier:kXXScriptListCellReuseIdentifier forIndexPath:indexPath];
    
    if (_selectedIndex == indexPath.row) {
        cell.checked = YES;
    } else {
        cell.checked = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_selectedIndex != indexPath.row) {
        NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
        XXSwipeableCell *lastCell = [tableView cellForRowAtIndexPath:lastIndex];
        lastCell.checked = NO;
        
        XXSwipeableCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
        currentCell.checked = YES;
        
        _selectedIndex = indexPath.row;
    }
    
}

#pragma mark - Override and disable edit row

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedStringFromTable(@"Edit", @"XXTouch", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
    }];
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedStringFromTable(@"Delete", @"XXTouch", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
    }];
    editAction.backgroundColor = STYLE_TINT_COLOR;
    deleteAction.backgroundColor = [UIColor dangerColor];
    return @[deleteAction, editAction];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
