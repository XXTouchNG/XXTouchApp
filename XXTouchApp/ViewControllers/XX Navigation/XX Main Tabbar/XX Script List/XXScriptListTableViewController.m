//
//  XXScriptListTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXToolbar.h"
#import "XXSwipeableCell.h"
#import "XXCreateItemTableViewController.h"
#import "XXItemAttributesTableViewController.h"
#import "XXScriptListTableViewController.h"
#import "XXLocalDataService.h"
#import "XXQuickLookService.h"
#import <MJRefresh/MJRefresh.h>

static NSString * const kXXScriptListTableViewControllerStoryboardID = @"kXXScriptListTableViewControllerStoryboardID";
static NSString * const kXXCreateItemTableViewControllerStoryboardID = @"kXXCreateItemTableViewControllerStoryboardID";
static NSString * const kXXItemAttributesTableViewControllerStoryboardID = @"kXXItemAttributesTableViewControllerStoryboardID";
static NSString * const kXXScriptListCellReuseIdentifier = @"kXXScriptListCellReuseIdentifier";
static NSString * const kXXItemPathKey = @"kXXItemPathKey";
static NSString * const kXXItemNameKey = @"kXXItemNameKey";

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

@property (nonatomic, copy) NSString *rootDirectory;
@property (nonatomic, copy) NSString *currentDirectory;
@property (nonatomic, strong) NSArray <NSDictionary *> *rootItemsDictionaryArr;

@property (nonatomic, assign) kXXScriptListSortMethod sortMethod;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *scanButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addItemButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pasteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortByButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteRangeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@property (weak, nonatomic) IBOutlet UIButton *footerLabel;

@end

@implementation XXScriptListTableViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    _selectedIndex = -1;
    _rootDirectory = ROOT_PATH;
    _currentDirectory = [_rootDirectory mutableCopy];
    _rootItemsDictionaryArr = @[];
    _sortMethod = kXXScriptListSortByNameAsc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;
    
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
    
    [self.footerLabel setTarget:self action:@selector(itemCountLabelTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadScriptListTableView];
    if ([[XXLocalDataService sharedInstance] pasteboardArr].count == 0) {
        _pasteButton.enabled = NO;
    } else {
        _pasteButton.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - MJRefresh Header

- (MJRefreshNormalHeader *)refreshHeader {
    if (!_refreshHeader) {
        MJRefreshNormalHeader *normalHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadScriptListTableView)];
        [normalHeader setTitle:NSLocalizedStringFromTable(@"Pull down", @"XXTouch", nil) forState:MJRefreshStateIdle];
        [normalHeader setTitle:NSLocalizedStringFromTable(@"Release", @"XXTouch", nil) forState:MJRefreshStatePulling];
        [normalHeader setTitle:NSLocalizedStringFromTable(@"Loading...", @"XXTouch", nil) forState:MJRefreshStateRefreshing];
        normalHeader.stateLabel.font = [UIFont systemFontOfSize:12.0];
        normalHeader.stateLabel.textColor = [UIColor lightGrayColor];
        normalHeader.lastUpdatedTimeLabel.hidden = YES;
        _refreshHeader = normalHeader;
    }
    return _refreshHeader;
}

- (void)setCurrentDirectory:(NSString *)currentDirectory {
    _currentDirectory = currentDirectory;
    self.title = [currentDirectory lastPathComponent];
}

- (void)reloadScriptListTableView {
    [self reloadScriptListTableData];
    [self.tableView reloadData];
    [self endScriptListRefresh];
}

- (void)reloadScriptListTableData {
    NSMutableArray *pathArr = [[NSMutableArray alloc] initWithArray:[FCFileManager listItemsInDirectoryAtPath:self.currentDirectory deep:NO]];
    
    if (pathArr.count == 0) {
        [_footerLabel setTitle:NSLocalizedStringFromTable(@"No Item", @"XXTouch", nil) forState:UIControlStateNormal];
    } else if (pathArr.count == 1) {
        [_footerLabel setTitle:NSLocalizedStringFromTable(@"1 Item", @"XXTouch", nil) forState:UIControlStateNormal];
    } else {
        [_footerLabel setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%d Items", @"XXTouch", nil), pathArr.count] forState:UIControlStateNormal];
    }
    
    NSMutableArray *attrArr = [[NSMutableArray alloc] init];
    
    NSMutableArray *dirArr = [[NSMutableArray alloc] init];
    NSMutableArray *fileArr = [[NSMutableArray alloc] init];
    
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
    
    [attrArr addObjectsFromArray:dirArr];
    [attrArr addObjectsFromArray:fileArr];
    
    _rootItemsDictionaryArr = attrArr;
}

- (void)endScriptListRefresh {
    if ([self.refreshHeader isRefreshing]) {
        [self.refreshHeader endRefreshing];
    }
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
    
    cell.itemPath = itemPath;
    cell.displayName = itemName;
    cell.itemAttrs = attrs;
    
    if (cell.selectable) {
        if (_selectedIndex == indexPath.row) {
            cell.checked = YES;
            [[XXLocalDataService sharedInstance] setSelectedScript:cell.itemPath];
        } else if ([cell.itemPath isEqualToString:[[XXLocalDataService sharedInstance] selectedScript]]) {
            _selectedIndex = indexPath.row;
            cell.checked = YES;
        } else {
            cell.checked = NO;
        }
    } else if (cell.isDirectory) {
        BOOL checked = [[XXLocalDataService sharedInstance] isSelectedScriptInPath:cell.itemPath];
        cell.checked = checked;
        if (checked) {
            _selectedIndex = indexPath.row;
        }
    }
    
    return cell;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        _scanButton.enabled =
        _addItemButton.enabled =
        _sortByButton.enabled =
        _shareButton.enabled =
        _deleteRangeButton.enabled = NO;
    } else {
        if ([[XXLocalDataService sharedInstance] pasteboardArr].count == 0) {
            _pasteButton.enabled = NO;
        }
        _scanButton.enabled =
        _addItemButton.enabled =
        _sortByButton.enabled = YES;
        _shareButton.enabled =
        _deleteRangeButton.enabled = NO;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView indexPathsForSelectedRows].count == 0) {
        if ([[XXLocalDataService sharedInstance] pasteboardArr].count == 0) {
            _pasteButton.enabled = NO;
        }
        _shareButton.enabled =
        _deleteRangeButton.enabled = NO;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEditing]) {
        _pasteButton.enabled =
        _shareButton.enabled =
        _deleteRangeButton.enabled = YES;
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
            
            [[XXLocalDataService sharedInstance] setSelectedScript:currentCell.itemPath];
        }
    } else {
        if (currentCell.isDirectory) {
            XXScriptListTableViewController *newController = [self.storyboard instantiateViewControllerWithIdentifier:kXXScriptListTableViewControllerStoryboardID];
            newController.currentDirectory = currentCell.itemPath;
            [self.navigationController pushViewController:newController animated:YES];
        } else {
            BOOL result = [XXQuickLookService viewFileWithStandardViewer:currentCell.itemPath
                                                    parentViewController:self.navigationController];
            if (!result) {
                [self.navigationController.view makeToast:NSLocalizedStringFromTable(@"Unknown File Type", @"XXTouch", nil)];
            }
        }
    }
}

#pragma mark - Override and disable edit row

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
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
        __block NSError *err = nil;
        @weakify(self);
        [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Yes", @"XXTouch", nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
            @strongify(self);
            self.navigationController.view.userInteractionEnabled = NO;
            [self.navigationController.view makeToastActivity:CSToastPositionCenter];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [FCFileManager removeItemAtPath:itemPath error:&err]; // This may be time comsuming
                dispatch_async_on_main_queue(^{
                    self.navigationController.view.userInteractionEnabled = YES;
                    [self.navigationController.view hideToastActivity];
                    if (err == nil) {
                        [self reloadScriptListTableData];
                        [tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationFade];
                        [self setEditing:NO animated:YES];
                    } else {
                        [self.navigationController.view makeToast:[err localizedDescription]];
                    }
                });
            });
        }];
        [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Cancel", @"XXTouch", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
            
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

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    XXSwipeableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:kXXItemAttributesTableViewControllerStoryboardID];
    XXItemAttributesTableViewController *viewController = (XXItemAttributesTableViewController *)navController.topViewController;
    viewController.currentName = [cell.itemAttrs objectForKey:kXXItemNameKey];
    viewController.currentPath = [cell.itemAttrs objectForKey:kXXItemPathKey];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (IBAction)toolbarButtonTapped:(id)sender {
    if (sender == _scanButton) {
        
    } else if (sender == _addItemButton) {
        UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:kXXCreateItemTableViewControllerStoryboardID];
        XXCreateItemTableViewController *viewController = (XXCreateItemTableViewController *)navController.topViewController;
        viewController.currentDirectory = self.currentDirectory;
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    } else if (sender == _pasteButton) {
        [self pasteButtonTapped];
    } else if (sender == _sortByButton) {
        if (_sortMethod == kXXScriptListSortByNameAsc) {
            self.sortMethod = kXXScriptListSortByModificationDesc;
            [self.sortByButton setImage:[UIImage imageNamed:@"sort-number"]];
        } else if (_sortMethod == kXXScriptListSortByModificationDesc) {
            self.sortMethod = kXXScriptListSortByNameAsc;
            [self.sortByButton setImage:[UIImage imageNamed:@"sort-alpha"]];
        }
    } else if (sender == _deleteRangeButton) {
        __block NSArray <NSIndexPath *> *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
        
        NSString *formatString = nil;
        if (selectedIndexPaths.count == 1) {
            formatString = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Delete 1 item?\nThis operation cannot be revoked.", @"XXTouch", nil)];
        } else {
            formatString = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Delete %d items?\nThis operation cannot be revoked.", @"XXTouch", nil), selectedIndexPaths.count];
        }
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Delete Confirm", @"XXTouch", nil)
                                                         andMessage:formatString];
        @weakify(self);
        [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Yes", @"XXTouch", nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
            @strongify(self);
            [self deleteSelectedRowsAndItems:selectedIndexPaths];
            [self reloadScriptListTableData];
            [self.tableView deleteRowsAtIndexPaths:selectedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [self setEditing:NO animated:YES];
        }];
        [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Cancel", @"XXTouch", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
            
        }];
        [alertView show];
    } else if (sender == _shareButton) {
        NSArray <NSIndexPath *> *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
        NSMutableArray <NSURL *> *pathsArr = [[NSMutableArray alloc] init];
        for (NSIndexPath *indexPath in selectedIndexPaths) {
            XXSwipeableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if (!cell.isDirectory) {
                [pathsArr addObject:[NSURL fileURLWithPath:cell.itemPath]];
            }
        }
        if (pathsArr.count != 0) {
            UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:pathsArr applicationActivities:nil];
            [self.navigationController presentViewController:controller animated:YES completion:nil];
        } else {
            [self.navigationController.view makeToast:NSLocalizedStringFromTable(@"You cannot share directory.", @"XXTouch", nil)];
        }
    }
}

- (void)setSortMethod:(kXXScriptListSortMethod)sortMethod {
    _sortMethod = sortMethod;
    [self reloadScriptListTableView];
}

- (void)deleteSelectedRowsAndItems:(NSArray <NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        XXSwipeableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString *itemPath = cell.itemPath;
        NSError *err = nil;
        [FCFileManager removeItemAtPath:itemPath error:&err];
    }
}

- (void)pasteButtonTapped {
    // Start Alert View
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:nil];
    
    // Set Paste / Link Action
    NSString *pasteStr = nil;
    NSString *linkStr = nil;
    __block NSMutableArray *pasteArr = [[XXLocalDataService sharedInstance] pasteboardArr];
    if (pasteArr.count != 0) {
        if (pasteArr.count == 1) {
            pasteStr = NSLocalizedStringFromTable(@"Paste 1 item", @"XXTouch", nil);
            linkStr = NSLocalizedStringFromTable(@"Create 1 link", @"XXTouch", nil);
        } else {
            pasteStr = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Paste %d items", @"XXTouch", nil), pasteArr.count];
            linkStr = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Create %d links", @"XXTouch", nil), pasteArr.count];
        }
        __block NSError *err = nil;
        __block NSString *currentPath = self.currentDirectory;
        __block kXXPasteboardType pasteboardType = [[XXLocalDataService sharedInstance] pasteboardType];
        @weakify(self);
        [alertView addButtonWithTitle:pasteStr type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
            @strongify(self);
            self.navigationController.view.userInteractionEnabled = NO;
            [self.navigationController.view makeToastActivity:CSToastPositionCenter];
            if (pasteboardType == kXXPasteboardTypeCut) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    for (NSString *originPath in pasteArr) {
                        NSString *destPath = [currentPath stringByAppendingPathComponent:[originPath lastPathComponent]];
                        [FCFileManager moveItemAtPath:originPath toPath:destPath overwrite:NO error:&err]; // This may be time consuming
                    }
                    dispatch_async_on_main_queue(^{
                        self.navigationController.view.userInteractionEnabled = YES;
                        [self.navigationController.view hideToastActivity];
                        if (err != nil) {
                            [self.navigationController.view makeToast:[err localizedDescription]];
                        } else {
                            [pasteArr removeAllObjects];
                            self.pasteButton.enabled = NO;
                            [self reloadScriptListTableView];
                        }
                    });
                });
            } else if (pasteboardType == kXXPasteboardTypeCopy) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    for (NSString *originPath in pasteArr) {
                        NSString *destPath = [currentPath stringByAppendingPathComponent:[originPath lastPathComponent]];
                        [FCFileManager copyItemAtPath:originPath toPath:destPath overwrite:NO error:&err]; // This may be time consuming
                    }
                    dispatch_async_on_main_queue(^{
                        self.navigationController.view.userInteractionEnabled = YES;
                        [self.navigationController.view hideToastActivity];
                        if (err != nil) {
                            [self.navigationController.view makeToast:[err localizedDescription]];
                        } else {
                            [self reloadScriptListTableView];
                        }
                    });
                });
            }
        }];
        if (pasteboardType == kXXPasteboardTypeCopy) {
            @weakify(self);
            [alertView addButtonWithTitle:linkStr type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                @strongify(self);
                for (NSString *originPath in pasteArr) {
                    NSString *destPath = [currentPath stringByAppendingPathComponent:[originPath lastPathComponent]];
                    [[NSFileManager defaultManager] createSymbolicLinkAtPath:destPath withDestinationPath:originPath error:&err];
                }
                if (err != nil) {
                    [self.navigationController.view makeToast:[err localizedDescription]];
                } else {
                    [self reloadScriptListTableView];
                }
            }];
        }
    }
    
    // Set Copy / Cut Action
    NSString *copyStr = nil;
    NSString *cutStr = nil;
    NSArray <NSIndexPath *> *selectedIndexes = [self.tableView indexPathsForSelectedRows];
    if (selectedIndexes.count != 0) {
        __block NSMutableArray <NSString *> *selectedPaths = [[NSMutableArray alloc] init];
        for (NSIndexPath *path in selectedIndexes) {
            XXSwipeableCell *cell = [self.tableView cellForRowAtIndexPath:path];
            [selectedPaths addObject:cell.itemPath];
        }
        if (selectedIndexes.count == 1) {
            copyStr = NSLocalizedStringFromTable(@"Copy 1 item", @"XXTouch", nil);
            cutStr = NSLocalizedStringFromTable(@"Cut 1 item", @"XXTouch", nil);
        } else {
            copyStr = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Copy %d items", @"XXTouch", nil), selectedIndexes.count];
            cutStr = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Cut %d items", @"XXTouch", nil), selectedIndexes.count];
        }
        if ([self isEditing]) {
            @weakify(self);
            [alertView addButtonWithTitle:copyStr type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                @strongify(self);
                [[XXLocalDataService sharedInstance] setPasteboardType:kXXPasteboardTypeCopy];
                [[XXLocalDataService sharedInstance] setPasteboardArr:selectedPaths];
                if (self.isEditing) {
                    [self setEditing:NO animated:YES];
                }
            }];
            [alertView addButtonWithTitle:cutStr type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                @strongify(self);
                [[XXLocalDataService sharedInstance] setPasteboardType:kXXPasteboardTypeCut];
                [[XXLocalDataService sharedInstance] setPasteboardArr:selectedPaths];
                if (self.isEditing) {
                    [self setEditing:NO animated:YES];
                }
            }];
        }
    }
    
    [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Cancel", @"XXTouch", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
        
    }];
    
    // Show Alert
    [alertView show];
}

- (void)itemCountLabelTapped:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.currentDirectory];
    [self.navigationController.view makeToast:NSLocalizedStringFromTable(@"The absolute path has been copied to the clipboard.", @"XXTouch", nil)];
}

- (void)dealloc {
    CYLog(@"");
}

@end
