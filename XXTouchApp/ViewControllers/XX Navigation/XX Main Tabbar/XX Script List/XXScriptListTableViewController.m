//
//  XXScriptListTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXToolbar.h"
#import "XXSwipeableCell.h"
#import "XXScriptListTableViewController.h"
#import "XXLocalDataService.h"
#import <MJRefresh/MJRefresh.h>

static NSString * const kXXScriptListCellReuseIdentifier = @"kXXScriptListCellReuseIdentifier";
static NSString * const kXXItemPathKey = @"kXXItemPathKey";
static NSString * const kXXItemNameKey = @"kXXItemNameKey";
static NSString * const kXXItemUpperKey = @"kXXItemUpperKey";

enum {
    kXXScriptListCellSection = 0,
};

typedef enum : NSUInteger {
    kXXScriptListSortByNameAsc,
    kXXScriptListSortByModificationDesc,
} kXXScriptListSortMethod;

@interface XXScriptListTableViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) MJRefreshNormalHeader *refreshHeader;
@property (weak, nonatomic) IBOutlet XXToolbar *topToolbar;

@property (nonatomic, strong) NSString *rootDirectory;
@property (nonatomic, strong) NSString *currentDirectory;
@property (nonatomic, strong) NSString *upperDirectory;
@property (nonatomic, strong) NSArray <NSDictionary *> *rootItemsDictionaryArr;

@property (nonatomic, assign) kXXScriptListSortMethod sortMethod;

@end

@implementation XXScriptListTableViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    _rootDirectory = [[XXLocalDataService sharedInstance] rootPath];
    _currentDirectory = [_rootDirectory mutableCopy];
    _upperDirectory = nil;
    _rootItemsDictionaryArr = @[];
    _sortMethod = kXXScriptListSortByNameAsc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromTable(@"My Scripts", @"XXTouch", nil); // Override
    self.clearsSelectionOnViewWillAppear = YES; // Override
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.scrollIndicatorInsets =
    self.tableView.contentInset =
    UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
    
    self.tableView.mj_header = self.refreshHeader;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.allowsSelection = YES;
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
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

- (void)setCurrentDirectory:(NSString *)currentDirectory {
    _currentDirectory = currentDirectory;
    if ([currentDirectory isEqualToString:_rootDirectory]) {
        _upperDirectory = nil;
    } else {
        _upperDirectory = [currentDirectory stringByDeletingLastPathComponent];
    }
}

- (void)reloadScriptListTableView {
    
    if ([self.tableView isEditing]) {
        [self endScriptListRefresh];
        return;
    }
    
    [self reloadScriptListTableData];
    [self.tableView reloadData];
    [self endScriptListRefresh];
}

- (void)reloadScriptListTableData {
    NSMutableArray *pathArr = [[NSMutableArray alloc] initWithArray:[FCFileManager listItemsInDirectoryAtPath:self.currentDirectory deep:NO]];
    
    NSMutableArray *attrArr = [[NSMutableArray alloc] init];
    
    NSMutableArray *dirArr = [[NSMutableArray alloc] init];
    NSMutableArray *fileArr = [[NSMutableArray alloc] init];
    
    // Fetch Attributes
    for (NSString *itemPath in pathArr) {
        NSError *err = nil;
        NSDictionary *attrs = [FCFileManager attributesOfItemAtPath:itemPath
                                                              error:&err];
        NSMutableDictionary *mutAttrs = [[NSMutableDictionary alloc] initWithDictionary:attrs];
        [mutAttrs setObject:itemPath forKey:kXXItemPathKey];
        [mutAttrs setObject:[itemPath lastPathComponent] forKey:kXXItemNameKey];
        if (err == nil) {
            if ([mutAttrs objectForKey:NSFileType] == NSFileTypeDirectory) {
                [dirArr addObject:mutAttrs];
            } else {
                [fileArr addObject:mutAttrs];
            }
        }
    }
    
    // Sort
    if (self.sortMethod == kXXScriptListSortByNameAsc) {
        [dirArr sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
            return [obj1[kXXItemNameKey] compare:obj2[kXXItemNameKey] options:NSCaseInsensitiveSearch];
        }];
        [fileArr sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
            return [obj1[kXXItemNameKey] compare:obj2[kXXItemNameKey] options:NSCaseInsensitiveSearch];
        }];
    } else if (self.sortMethod == kXXScriptListSortByModificationDesc) {
        [dirArr sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
            return [obj1[NSFileModificationDate] compare:obj2[NSFileModificationDate]];
        }];
        [fileArr sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
            return [obj1[NSFileModificationDate] compare:obj2[NSFileModificationDate]];
        }];
    }
    
    // Combine
    [attrArr addObjectsFromArray:dirArr];
    [attrArr addObjectsFromArray:fileArr];
    
    // ..
    if (_upperDirectory != nil) {
        NSString *itemPath = _upperDirectory;
        [pathArr insertObject:itemPath atIndex:0];
        NSError *err = nil;
        NSDictionary *attrs = [FCFileManager attributesOfItemAtPath:itemPath
                                                              error:&err];
        NSMutableDictionary *mutAttrs = [[NSMutableDictionary alloc] initWithDictionary:attrs];
        [mutAttrs setObject:itemPath forKey:kXXItemPathKey];
        if (err == nil) {
            if ([mutAttrs objectForKey:NSFileType] == NSFileTypeDirectory) {
                [attrArr insertObject:mutAttrs atIndex:0];
            }
        }
    }
    
    CYLog(@"%@", pathArr);
    _rootItemsDictionaryArr = attrArr;
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
        return self.rootItemsDictionaryArr.count;
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
    NSDictionary *attrs = self.rootItemsDictionaryArr[indexPath.row];
    NSString *itemPath = [attrs objectForKey:kXXItemPathKey];
    NSString *itemName = [attrs objectForKey:kXXItemNameKey];
    CYLog(@"%@", attrs);
    
    if ([itemPath isEqualToString:_upperDirectory]) {
        cell.isUpperDirectory = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.isUpperDirectory = NO;
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }
    
    cell.itemPath = itemPath;
    cell.displayName = itemName;
    cell.itemAttrs = attrs;
    
    if (cell.selectable) {
        if (_selectedIndex == indexPath.row) {
            cell.checked = YES;
        } else {
            cell.checked = NO;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEditing]) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XXSwipeableCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (currentCell.selectable) {
        if (_selectedIndex != indexPath.row) {
            NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
            XXSwipeableCell *lastCell = [tableView cellForRowAtIndexPath:lastIndex];
            
            lastCell.checked = NO;
            currentCell.checked = YES;
            
            _selectedIndex = indexPath.row;
        }
    } else {
        if (currentCell.isDirectory) {
            self.currentDirectory = currentCell.itemPath;
            [self reloadScriptListTableView];
        } else {
            [self.navigationController.view makeToast:NSLocalizedStringFromTable(@"Unknown File Type", @"XXTouch", nil)];
        }
    }
}

#pragma mark - Override and disable edit row

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    XXSwipeableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.isUpperDirectory) {
        return NO;
    }
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedStringFromTable(@"Delete", @"XXTouch", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        XXSwipeableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        __block NSString *itemPath = cell.itemPath;
        NSString *displayName = cell.displayName;
        NSString *formatString = NSLocalizedStringFromTable(@"Delete %@?\nThis operation cannot be revoked.", @"XXTouch", nil);
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Delete Confirm", @"XXTouch", nil)
                                                         andMessage:[NSString stringWithFormat:formatString, displayName]];
        [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Yes", @"XXTouch", nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
            NSError *err = nil;
            [FCFileManager removeItemAtPath:itemPath error:&err];
            [self reloadScriptListTableData];
            [tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationFade];
            [tableView setEditing:NO animated:YES];
        }];
        [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Cancel", @"XXTouch", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
            [tableView setEditing:NO animated:YES];
        }];
        [alertView show];
    }];
    deleteAction.backgroundColor = [UIColor dangerColor];
    XXSwipeableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.editable) {
        UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedStringFromTable(@"Edit", @"XXTouch", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
        }];
        editAction.backgroundColor = STYLE_TINT_COLOR;
        return @[editAction, deleteAction];
    }
    return @[deleteAction];
}

@end
