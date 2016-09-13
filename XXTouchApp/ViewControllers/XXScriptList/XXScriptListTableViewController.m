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
#import "XXLocalNetService.h"
#import "XXQuickLookService.h"
#import "XXArchiveService.h"
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

@interface XXScriptListTableViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
SSZipArchiveDelegate,
UIGestureRecognizerDelegate,
XXToolbarDelegate
>

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) MJRefreshNormalHeader *refreshHeader;
@property (weak, nonatomic) IBOutlet XXToolbar *topToolbar;

@property (nonatomic, copy) NSString *rootDirectory;
@property (nonatomic, copy) NSString *currentDirectory;
@property (nonatomic, strong) NSArray <NSDictionary *> *rootItemsDictionaryArr;

@property (weak, nonatomic) IBOutlet UIButton *footerLabel;

@end

@implementation XXScriptListTableViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    _selectedIndex = -1;
    _rootDirectory = ROOT_PATH;
    _currentDirectory = [_rootDirectory mutableCopy];
    _rootItemsDictionaryArr = @[];
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
    
    self.topToolbar.tapDelegate = self;
    [self.topToolbar setItems:self.topToolbar.defaultToolbarButtons animated:YES];
    [self.footerLabel setTarget:self action:@selector(itemCountLabelTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[XXLocalDataService sharedInstance] selectedScript] == nil) {
        [self.refreshHeader beginRefreshing];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadScriptListTableView];
    // Pasteboard Event - ViewWillAppear
    if ([[XXLocalDataService sharedInstance] pasteboardArr].count == 0) {
        self.topToolbar.pasteButton.enabled = NO;
    } else {
        self.topToolbar.pasteButton.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
        normalHeader.lastUpdatedTimeLabel.hidden = YES;
        _refreshHeader = normalHeader;
    }
    return _refreshHeader;
}

#pragma mark - Reload Control

- (void)setCurrentDirectory:(NSString *)currentDirectory {
    _currentDirectory = currentDirectory;
    self.title = [currentDirectory lastPathComponent];
}

- (void)startMJRefreshing {
    [self launchSetup];
}

- (void)launchSetup {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        NSError *err = nil;
        BOOL result = [XXLocalNetService localGetSelectedScriptWithError:&err];
        dispatch_async_on_main_queue(^{
            if (!result) {
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:XXLString(@"Sync Failure")
                                                                 andMessage:XXLString(@"Failed to sync with daemon.\nTap to retry.")];
                [alertView addButtonWithTitle:XXLString(@"Retry")
                                         type:SIAlertViewButtonTypeDestructive
                                      handler:^(SIAlertView *alertView) {
                                          [self performSelector:@selector(launchSetup) withObject:nil afterDelay:0.5];
                                      }];
                [alertView addButtonWithTitle:XXLString(@"Cancel")
                                         type:SIAlertViewButtonTypeCancel
                                      handler:^(SIAlertView *alertView) {
                                          [self endMJRefreshing];
                                      }];
                [alertView show];
            } else {
                [self reloadScriptListTableView];
                [self endMJRefreshing];
            }
        });
    });
}

- (void)reloadScriptListTableView {
    [self reloadScriptListTableData];
    [self.tableView reloadData];
}

- (void)reloadScriptListTableData {
    NSMutableArray *pathArr = [[NSMutableArray alloc] initWithArray:[FCFileManager listItemsInDirectoryAtPath:self.currentDirectory deep:NO]];
    
    if (pathArr.count == 0) {
        [_footerLabel setTitle:XXLString(@"No Item") forState:UIControlStateNormal];
    } else if (pathArr.count == 1) {
        [_footerLabel setTitle:XXLString(@"1 Item") forState:UIControlStateNormal];
    } else {
        [_footerLabel setTitle:[NSString stringWithFormat:XXLString(@"%d Items"), pathArr.count] forState:UIControlStateNormal];
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
    
    if ([[XXLocalDataService sharedInstance] sortMethod] == kXXScriptListSortByNameAsc) {
        [self.topToolbar.sortByButton setImage:[UIImage imageNamed:@"sort-alpha"]];
        [dirArr sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
            return [obj1[kXXItemNameKey] compare:obj2[kXXItemNameKey] options:NSCaseInsensitiveSearch];
        }];
        [fileArr sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
            return [obj1[kXXItemNameKey] compare:obj2[kXXItemNameKey] options:NSCaseInsensitiveSearch];
        }];
    } else if ([[XXLocalDataService sharedInstance] sortMethod] == kXXScriptListSortByModificationDesc) {
        [self.topToolbar.sortByButton setImage:[UIImage imageNamed:@"sort-number"]];
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

- (void)endMJRefreshing {
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
        if ([cell.itemPath isEqualToString:[[XXLocalDataService sharedInstance] selectedScript]]) {
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
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPress:)];
    longPressGesture.delegate = self;
    [cell addGestureRecognizer:longPressGesture];
    
    return cell;
}

#pragma mark - Long Press Gesture for Block

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self isEditing]) {
        return NO;
    }
    return YES;
}

- (void)cellLongPress:(UIGestureRecognizer *)recognizer {
    if (![self isEditing]) {
        [self setEditing:YES animated:YES];
    }
}

#pragma mark - Table View Controller Editing Control

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    // Pasteboard Event - setEditing
    if (editing) {
        [self.topToolbar setItems:self.topToolbar.editingToolbarButtons animated:YES];
    } else {
        self.topToolbar.shareButton.enabled =
        self.topToolbar.compressButton.enabled =
        self.topToolbar.trashButton.enabled = NO;
        [self.topToolbar setItems:self.topToolbar.defaultToolbarButtons animated:YES];
        if ([[XXLocalDataService sharedInstance] pasteboardArr].count == 0) {
            self.topToolbar.pasteButton.enabled = NO;
        }
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView indexPathsForSelectedRows].count == 0) {
        if ([[XXLocalDataService sharedInstance] pasteboardArr].count == 0) {
            self.topToolbar.pasteButton.enabled = NO;
        }
        self.topToolbar.shareButton.enabled =
        self.topToolbar.compressButton.enabled =
        self.topToolbar.trashButton.enabled = NO;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEditing]) {
        self.topToolbar.pasteButton.enabled =
        self.topToolbar.shareButton.enabled =
        self.topToolbar.compressButton.enabled =
        self.topToolbar.trashButton.enabled = YES;
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    __block XXSwipeableCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (currentCell.selectable) {
        if (_selectedIndex != indexPath.row) {
            NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
            __block XXSwipeableCell *lastCell = [tableView cellForRowAtIndexPath:lastIndex];
            SendConfigAction([XXLocalNetService localSetSelectedScript:currentCell.itemPath error:&err], lastCell.checked = NO; currentCell.checked = YES; _selectedIndex = indexPath.row;);
        }
    } else {
        if (currentCell.isDirectory) {
            XXScriptListTableViewController *newController = [self.storyboard instantiateViewControllerWithIdentifier:kXXScriptListTableViewControllerStoryboardID];
            newController.currentDirectory = currentCell.itemPath;
            [self.navigationController pushViewController:newController animated:YES];
        } else {
            BOOL result = [XXQuickLookService viewFileWithStandardViewer:currentCell.itemPath
                                                    parentViewController:self];
            if (!result) {
                result = [XXArchiveService unArchiveZip:currentCell.itemPath
                                            toDirectory:self.currentDirectory
                                   parentViewController:self];
            }
            if (!result) {
                [self.navigationController.view makeToast:XXLString(@"Unsupported File Type")];
            }
        }
    }
}

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
    NSMutableArray <UITableViewRowAction *> *actionsArr = [[NSMutableArray alloc] init];
    
    __block XXSwipeableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectable) {
        @weakify(self);
        UITableViewRowAction *runAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:XXLString(@"Run") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            @strongify(self);
            [self setEditing:NO animated:YES];
            SendConfigAction([XXLocalNetService localLaunchSelectedScript:cell.itemPath error:&err], nil);
        }];
        runAction.backgroundColor = [UIColor blueberryColor];
        [actionsArr addObject:runAction];
    }
    if (cell.editable) {
        UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:XXLString(@"Edit") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
        }];
        editAction.backgroundColor = STYLE_TINT_COLOR;
        [actionsArr addObject:editAction];
    }
    @weakify(self);
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:XXLString(@"Delete") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        @strongify(self);
        [self setEditing:NO animated:YES];
        __block NSString *itemPath = cell.itemPath;
        __block NSError *err = nil;
        self.navigationController.view.userInteractionEnabled = NO;
        [self.navigationController.view makeToastActivity:CSToastPositionCenter];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [FCFileManager removeItemAtPath:itemPath error:&err]; // This may be time comsuming
            if (cell.checked) {
                [[XXLocalDataService sharedInstance] setSelectedScript:nil];
            }
            dispatch_async_on_main_queue(^{
                self.navigationController.view.userInteractionEnabled = YES;
                [self.navigationController.view hideToastActivity];
                if (err == nil) {
                    [self reloadScriptListTableData];
                    [tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationFade];
                } else {
                    [self.navigationController.view makeToast:[err localizedDescription]];
                }
            });
        });
    }];
    deleteAction.backgroundColor = [UIColor dangerColor];
    [actionsArr addObject:deleteAction];
    return actionsArr;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    XXSwipeableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:kXXItemAttributesTableViewControllerStoryboardID];
    XXItemAttributesTableViewController *viewController = (XXItemAttributesTableViewController *)navController.topViewController;
    viewController.currentName = [cell.itemAttrs objectForKey:kXXItemNameKey];
    viewController.currentPath = [cell.itemAttrs objectForKey:kXXItemPathKey];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Actions

- (void)itemCountLabelTapped:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.currentDirectory];
    [self.navigationController.view makeToast:XXLString(@"Absolute path copied to the clipboard.")];
}

- (void)toolbarButtonTapped:(UIBarButtonItem *)sender {
    if (sender == self.topToolbar.scanButton) {
        
    } else if (sender == self.topToolbar.addItemButton) {
        UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:kXXCreateItemTableViewControllerStoryboardID];
        XXCreateItemTableViewController *viewController = (XXCreateItemTableViewController *)navController.topViewController;
        viewController.currentDirectory = self.currentDirectory;
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    } else if (sender == self.topToolbar.pasteButton) {
        // Start Alert View
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:nil];
        
        // Set Paste / Link Action
        NSString *pasteStr = nil;
        NSString *linkStr = nil;
        __block NSMutableArray *pasteArr = [[XXLocalDataService sharedInstance] pasteboardArr];
        if (pasteArr.count != 0) {
            if (pasteArr.count == 1) {
                pasteStr = XXLString(@"Paste 1 item");
                linkStr = XXLString(@"Create 1 link");
            } else {
                pasteStr = [NSString stringWithFormat:XXLString(@"Paste %d items"), pasteArr.count];
                linkStr = [NSString stringWithFormat:XXLString(@"Create %d links"), pasteArr.count];
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
                                self.topToolbar.pasteButton.enabled = NO;
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
                copyStr = XXLString(@"Copy 1 item");
                cutStr = XXLString(@"Cut 1 item");
            } else {
                copyStr = [NSString stringWithFormat:XXLString(@"Copy %d items"), selectedIndexes.count];
                cutStr = [NSString stringWithFormat:XXLString(@"Cut %d items"), selectedIndexes.count];
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
        
        [alertView addButtonWithTitle:XXLString(@"Cancel") type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
            
        }];
        
        // Show Alert
        [alertView show];
    } else if (sender == self.topToolbar.sortByButton) {
        if ([[XXLocalDataService sharedInstance] sortMethod] == kXXScriptListSortByNameAsc) {
            [[XXLocalDataService sharedInstance] setSortMethod:kXXScriptListSortByModificationDesc];
            [self.topToolbar.sortByButton setImage:[UIImage imageNamed:@"sort-number"]];
        } else if ([[XXLocalDataService sharedInstance] sortMethod] == kXXScriptListSortByModificationDesc) {
            [[XXLocalDataService sharedInstance] setSortMethod:kXXScriptListSortByNameAsc];
            [self.topToolbar.sortByButton setImage:[UIImage imageNamed:@"sort-alpha"]];
        }
        [self reloadScriptListTableView];
    } else if (sender == self.topToolbar.trashButton) {
        __block NSArray <NSIndexPath *> *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
        
        NSString *formatString = nil;
        if (selectedIndexPaths.count == 1) {
            formatString = [NSString stringWithFormat:XXLString(@"Delete 1 item?\nThis operation cannot be revoked.")];
        } else {
            formatString = [NSString stringWithFormat:XXLString(@"Delete %d items?\nThis operation cannot be revoked."), selectedIndexPaths.count];
        }
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:XXLString(@"Delete Confirm")
                                                         andMessage:formatString];
        @weakify(self);
        [alertView addButtonWithTitle:XXLString(@"Yes") type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
            @strongify(self);
            for (NSIndexPath *indexPath in selectedIndexPaths) {
                XXSwipeableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                NSString *itemPath = cell.itemPath;
                NSError *err = nil;
                if (cell.checked) {
                    [[XXLocalDataService sharedInstance] setSelectedScript:nil];
                }
                [FCFileManager removeItemAtPath:itemPath error:&err];
            }
            [self reloadScriptListTableData];
            [self.tableView deleteRowsAtIndexPaths:selectedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [self setEditing:NO animated:YES];
        }];
        [alertView addButtonWithTitle:XXLString(@"Cancel") type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
            
        }];
        [alertView show];
    } else if (sender == self.topToolbar.shareButton) {
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
            [self.navigationController.view makeToast:XXLString(@"You cannot share directory.")];
        }
    } else if (sender == self.topToolbar.compressButton) {
        __block NSArray <NSIndexPath *> *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
        NSString *formatString = nil;
        if (selectedIndexPaths.count == 1) {
            formatString = [NSString stringWithFormat:XXLString(@"Compress 1 item?")];
        } else {
            formatString = [NSString stringWithFormat:XXLString(@"Compress %d items?"), selectedIndexPaths.count];
        }
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:XXLString(@"Archive Confirm")
                                                         andMessage:formatString];
        @weakify(self);
        [alertView addButtonWithTitle:XXLString(@"Yes") type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
            @strongify(self);
            if (self.isEditing) {
                [self setEditing:NO animated:YES];
            }
            NSMutableArray <NSString *> *pathsArr = [[NSMutableArray alloc] init];
            for (NSIndexPath *indexPath in selectedIndexPaths) {
                XXSwipeableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                [pathsArr addObject:cell.itemPath];
            }
            if (pathsArr.count != 0) {
                [XXArchiveService archiveItems:pathsArr
                                   toDirectory:self.currentDirectory
                          parentViewController:self];
            }
        }];
        [alertView addButtonWithTitle:XXLString(@"Cancel") type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
            
        }];
        [alertView show];
    }
}

#pragma mark - SSZipArchiveDelegate

- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path
                                zipInfo:(unz_global_info)zipInfo
                           unzippedPath:(NSString *)unzippedPath
{
    dispatch_async_on_main_queue(^{
        [self reloadScriptListTableView];
    });
}

- (void)zipArchiveDidCreatedArchiveAtPath:(NSString *)path {
    dispatch_async_on_main_queue(^{
        [self reloadScriptListTableView];
    });
}

- (void)dealloc {
    CYLog(@"");
}

@end
