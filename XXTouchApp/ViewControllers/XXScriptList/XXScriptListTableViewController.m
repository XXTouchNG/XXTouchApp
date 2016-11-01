//
//  XXScriptListTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXLocalDataService.h"
#import "XXLocalNetService.h"
#import "XXQuickLookService.h"
#import "XXArchiveService.h"

#import <MJRefresh/MJRefresh.h>
#import "XXToolbar.h"
#import "XXSwipeableCell.h"
#import "XXInsetsLabel.h"

#import "XXNavigationViewController.h"
#import "XXScriptListTableViewController.h"
#import "XXCreateItemTableViewController.h"
#import "XXItemAttributesTableViewController.h"

#import "UIViewController+MSLayoutSupport.h"
#import "NSFileManager+RealDestination.h"

static NSString * const kXXScriptListCellReuseIdentifier = @"kXXScriptListCellReuseIdentifier";
static NSString * const kXXRewindSegueIdentifier = @"kXXRewindSegueIdentifier";

@interface XXScriptListTableViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
SSZipArchiveDelegate,
UIGestureRecognizerDelegate,
XXToolbarDelegate,
UISearchDisplayDelegate
>

@property (nonatomic, strong) MJRefreshNormalHeader *refreshHeader;
@property (weak, nonatomic) IBOutlet XXToolbar *topToolbar;

@property (nonatomic, assign, readonly) BOOL isRootDirectory;
@property (nonatomic, assign, readonly) BOOL hidesMainPath;
@property (nonatomic, strong) NSArray <NSDictionary *> *rootItemsDictionaryArr;

@property (weak, nonatomic) IBOutlet UIButton *footerLabel;

@property (nonatomic, strong) UIDocumentInteractionController *documentController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, copy) NSString *relativePath;

@end

@implementation XXScriptListTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.searchDisplayController.active) {
        return UIStatusBarStyleDefault;
    }
    return UIStatusBarStyleLightContent;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.currentDirectory = [ROOT_PATH mutableCopy];
    self.rootItemsDictionaryArr = @[];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchDisplayController.delegate = self;
    
    self.tableView.scrollIndicatorInsets =
    self.tableView.contentInset =
    UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
    
    self.tableView.mj_header = self.refreshHeader;
    
    self.tableView.allowsSelection = YES;
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    self.topToolbar.tapDelegate = self;
    if (_selectBootscript) {
        self.navigationItem.rightBarButtonItem = nil;
        [self.topToolbar setItems:self.topToolbar.selectingBootscriptButtons animated:YES];
    } else {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        [self.topToolbar setItems:self.topToolbar.defaultToolbarButtons animated:YES];
    }
    [self.footerLabel setTarget:self action:@selector(itemCountLabelTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[XXLocalDataService sharedInstance] selectedScript] == nil) {
        [self.refreshHeader beginRefreshing];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadScriptListTableView];
    self.topToolbar.pasteButton.enabled = [[XXLocalDataService sharedInstance] pasteboardArr].count != 0;
    if (self.isRootDirectory) {
        self.title = NSLocalizedString(@"My Scripts", nil);
    } else {
        self.title = [self.currentDirectory lastPathComponent];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self isEditing]) {
        [self setEditing:NO animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - MJRefresh Header

- (MJRefreshNormalHeader *)refreshHeader {
    if (!_refreshHeader) {
        MJRefreshNormalHeader *normalHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(startMJRefreshing)];
        [normalHeader setTitle:NSLocalizedString(@"Pull down", nil) forState:MJRefreshStateIdle];
        [normalHeader setTitle:NSLocalizedString(@"Release", nil) forState:MJRefreshStatePulling];
        [normalHeader setTitle:NSLocalizedString(@"Loading...", nil) forState:MJRefreshStateRefreshing];
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
    NSString *homePath = ROOT_PATH;
    NSString *rootPath = [[XXLocalDataService sharedInstance] mainPath];
    if ([currentDirectory isEqualToString:homePath]) {
        self.relativePath = @"~";
    } else if ([currentDirectory hasPrefix:[homePath stringByAppendingString:@"/"]]) {
        self.relativePath = [@"~" stringByAppendingString:[currentDirectory substringFromIndex:homePath.length]];
    } else if ([currentDirectory isEqualToString:rootPath]) {
        self.relativePath = @"/";
    } else if ([currentDirectory hasPrefix:[rootPath stringByAppendingString:@"/"]]) {
        self.relativePath = [@"/" stringByAppendingString:[currentDirectory substringFromIndex:(rootPath.length + 1)]];
    } else {
        self.relativePath = currentDirectory;
    }
}

- (void)startMJRefreshing {
    [self launchSetup];
}

- (void)launchSetup {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        NSError *err = nil;
        BOOL result = (_selectBootscript) ?
        [XXLocalNetService localGetStartUpConfWithError:&err] :
        [XXLocalNetService localGetSelectedScriptWithError:&err];
        dispatch_async_on_main_queue(^{
            if (!result) {
                if (self.isRootDirectory && isJailbroken() && !needsRespring()) {
                    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Sync Failure", nil)
                                                                     andMessage:NSLocalizedString(@"Failed to sync with daemon.\nTap to retry.", nil)];
                    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)
                                             type:SIAlertViewButtonTypeCancel
                                          handler:^(SIAlertView *alert) {
                                              [self endMJRefreshing];
                                          }];
                    [alertView addButtonWithTitle:NSLocalizedString(@"Retry", nil)
                                             type:SIAlertViewButtonTypeDestructive
                                          handler:^(SIAlertView *alert) {
                                              [self performSelector:@selector(launchSetup) withObject:nil afterDelay:0.5];
                                          }];
                    [alertView show];
                    return;
                } else {
                    [self.navigationController.view makeToast:[err localizedDescription]];
                }
            }
            [self reloadScriptListTableView];
            [self endMJRefreshing];
        });
    });
}

- (void)reloadScriptListTableView {
    [self reloadScriptListTableData];
    [self.tableView reloadData];
}

- (void)reloadScriptListTableData {
    NSMutableArray *pathArr = [[NSMutableArray alloc] initWithArray:[FCFileManager listItemsInDirectoryAtPath:self.currentDirectory deep:NO]];
    
    // Item Counting
    NSString *freeSpace = [FCFileManager sizeFormatted:@([[UIDevice currentDevice] diskSpaceFree])];
    NSString *footerTitle = @"";
    if (pathArr.count == 0) {
        footerTitle = NSLocalizedString(@"No Item", nil);
    } else if (pathArr.count == 1) {
        footerTitle = NSLocalizedString(@"1 Item", nil);
    } else {
        footerTitle = [NSString stringWithFormat:NSLocalizedString(@"%d Items", nil), pathArr.count];
    }
    footerTitle = [footerTitle stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@", %@ free", nil), freeSpace]];
    [_footerLabel setTitle:footerTitle forState:UIControlStateNormal];
    
    // Items Fetching
    NSMutableArray *dirArr = [[NSMutableArray alloc] init];
    NSMutableArray *fileArr = [[NSMutableArray alloc] init];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    for (NSString *itemPath in pathArr) {
        NSError *err = nil;
        NSDictionary *attrs = [FCFileManager attributesOfItemAtPath:itemPath
                                                              error:&err];
        if (err == nil) {
            BOOL sortAtTop = NO;
            NSMutableDictionary *mutAttrs = [[NSMutableDictionary alloc] initWithDictionary:attrs];
            mutAttrs[kXXItemRealPathKey] = itemPath;
            mutAttrs[kXXItemPathKey] = itemPath;
            mutAttrs[kXXItemNameKey] = [itemPath lastPathComponent];
            NSString *fileType = mutAttrs[NSFileType];
            if ([fileType isEqualToString:NSFileTypeDirectory]) {
                sortAtTop = YES;
            } else if ([fileType isEqualToString:NSFileTypeSymbolicLink]) {
                NSError *err = nil;
                NSString *destPath = [fileManager realDestinationOfSymbolicLinkAtPath:itemPath error:&err];
                if (!err) {
                    NSDictionary *destAttrs = [FCFileManager attributesOfItemAtPath:destPath error:&err];
                    if (!err) {
                        mutAttrs[kXXItemSymbolAttrsKey] = destAttrs;
                        mutAttrs[kXXItemRealPathKey] = destPath;
                        if ([destAttrs[NSFileType] isEqualToString:NSFileTypeDirectory]) {
                            sortAtTop = YES;
                        }
                    }
                }
            }
            sortAtTop ? [dirArr addObject:mutAttrs] : [fileArr addObject:mutAttrs];
        }
    }
    
    // Items Sorting
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
            return [obj2[NSFileModificationDate] compare:obj1[NSFileModificationDate]];
        }];
        [fileArr sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
            return [obj2[NSFileModificationDate] compare:obj1[NSFileModificationDate]];
        }];
    }
    
    // Items Combining
    NSMutableArray *attrArr = [[NSMutableArray alloc] init];
    
    [attrArr addObjectsFromArray:dirArr];
    [attrArr addObjectsFromArray:fileArr];
    
    self.rootItemsDictionaryArr = attrArr;
}

- (BOOL)hidesMainPath {
    return [[[[XXLocalDataService sharedInstance] localUserConfig] objectForKey:kXXLocalConfigHidesMainPath] boolValue];
}

- (void)endMJRefreshing {
    if ([self.refreshHeader isRefreshing]) {
        [self.refreshHeader endRefreshing];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (self.isRootDirectory && self.hidesMainPath == NO) {
            return 1;
        } else {
            return 0;
        }
    } else if (section == 1) {
        return self.rootItemsDictionaryArr.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return self.relativePath;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 24.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        NSString *displayPath = [self.relativePath mutableCopy];
        if (displayPath.length == 0) {
            displayPath = @"/";
        }
        XXInsetsLabel *sectionNameLabel = [[XXInsetsLabel alloc] init];
        sectionNameLabel.text = displayPath;
        sectionNameLabel.textColor = [UIColor blackColor];
        sectionNameLabel.backgroundColor = [UIColor colorWithWhite:.96f alpha:.9f];
        sectionNameLabel.font = [UIFont italicSystemFontOfSize:14.f];
        sectionNameLabel.edgeInsets = UIEdgeInsetsMake(0, 12.f, 0, 12.f);
        sectionNameLabel.numberOfLines = 1;
        sectionNameLabel.lineBreakMode = NSLineBreakByTruncatingHead;
        [sectionNameLabel sizeToFit];
        return sectionNameLabel;
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XXSwipeableCell *cell = [tableView dequeueReusableCellWithIdentifier:kXXScriptListCellReuseIdentifier forIndexPath:indexPath];
    
    NSDictionary *attrs = nil;
    if (indexPath.section == 0 && indexPath.row == 0 && self.isRootDirectory && self.hidesMainPath == NO) {
        NSError *err = nil;
        NSString *rootPath = [[XXLocalDataService sharedInstance] mainPath];
        if (rootPath) {
            NSDictionary *iAttrs = [FCFileManager attributesOfItemAtPath:rootPath
                                                                   error:&err];
            NSMutableDictionary *iMAttrs = [[NSMutableDictionary alloc] initWithDictionary:iAttrs];
            iMAttrs[kXXItemRealPathKey] = rootPath;
            iMAttrs[kXXItemPathKey] = rootPath;
            iMAttrs[kXXItemNameKey] = NSLocalizedString(@"Home Directory", nil);
            iMAttrs[kXXItemSpecialKey] = kXXItemSpecialValueHome;
            attrs = [iMAttrs copy];
        }
    } else {
        attrs = self.rootItemsDictionaryArr[(NSUInteger) indexPath.row];
    }
    
    cell.itemAttrs = attrs;
    cell.selectBootscript = self.selectBootscript;
    
    if (cell.isSelectable) {
        NSString *highlightedItemPath = (_selectBootscript) ?
        [[XXLocalDataService sharedInstance] startUpConfigScriptPath] :
        [[XXLocalDataService sharedInstance] selectedScript];
        cell.checked = [attrs[kXXItemRealPathKey] isEqualToString:highlightedItemPath];
    } else if (cell.isDirectory) {
        cell.checked = (_selectBootscript) ?
        [[XXLocalDataService sharedInstance] isSelectedStartUpScriptInPath:attrs[kXXItemRealPathKey]] :
        [[XXLocalDataService sharedInstance] isSelectedScriptInPath:attrs[kXXItemRealPathKey]];
    }
    
    if (_selectBootscript) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = cell.canOperate ?
        UITableViewCellAccessoryDetailDisclosureButton :
        UITableViewCellAccessoryDisclosureIndicator;
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPress:)];
        longPressGesture.delegate = self;
        [cell addGestureRecognizer:longPressGesture];
        NSMutableArray <MGSwipeButton *> *leftActionsArr = [[NSMutableArray alloc] init];
        NSMutableArray <MGSwipeButton *> *rightActionsArr = [[NSMutableArray alloc] init];
        if (cell.isSelectable) {
            @weakify(self);
            [leftActionsArr addObject:[MGSwipeButton buttonWithTitle:nil
                                                                icon:[[UIImage imageNamed:@"action-play"] imageByTintColor:[UIColor whiteColor]]
                                                     backgroundColor:[STYLE_TINT_COLOR colorWithAlphaComponent:1.f]
                                                              insets:UIEdgeInsetsMake(0, 24, 0, 24)
                                                            callback:^BOOL(MGSwipeTableCell *sender) {
                                                                @strongify(self);
                                                                [self setEditing:NO animated:YES];
                                                                XXSwipeableCell *currentCell = (XXSwipeableCell *)sender;
                                                                self.navigationController.view.userInteractionEnabled = NO;
                                                                [self.navigationController.view makeToastActivity:CSToastPositionCenter];
                                                                @weakify(self);
                                                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                                                    @strongify(self);
                                                                    NSError *err = nil;
                                                                    BOOL result = [XXLocalNetService localLaunchScript:currentCell.itemAttrs[kXXItemPathKey] error:&err];
                                                                    dispatch_async_on_main_queue(^{
                                                                        self.navigationController.view.userInteractionEnabled = YES;
                                                                        [self.navigationController.view hideToastActivity];
                                                                        if (!result) {
                                                                            if (err.code == 2) {
                                                                                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[err localizedDescription] andMessage:[err localizedFailureReason]];
                                                                                [alertView addButtonWithTitle:NSLocalizedString(@"OK", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                                                                                    
                                                                                }];
                                                                                [alertView show];
                                                                            } else {
                                                                                [self.navigationController.view makeToast:[err localizedDescription]];
                                                                            }
                                                                        }
                                                                    });
                                                                });
                                                                return YES;
                                                            }]];
        }
        if (cell.isEditable) {
            @weakify(self);
            [leftActionsArr addObject:[MGSwipeButton buttonWithTitle:nil icon:[[UIImage imageNamed:@"action-edit"] imageByTintColor:[UIColor whiteColor]]
                                                     backgroundColor:[STYLE_TINT_COLOR colorWithAlphaComponent:.8f]
                                                              insets:UIEdgeInsetsMake(0, 24, 0, 24)
                                                            callback:^BOOL(MGSwipeTableCell *sender) {
                                                                @strongify(self);
                                                                XXSwipeableCell *currentCell = (XXSwipeableCell *)sender;
                                                                [self setEditing:NO animated:YES];
                                                                BOOL result = [XXQuickLookService editFileWithStandardEditor:currentCell.itemAttrs[kXXItemRealPathKey] parentViewController:self];
                                                                if (!result) {
                                                                    [self.navigationController.view makeToast:NSLocalizedString(@"Unsupported file type", nil)];
                                                                }
                                                                return result;
                                                            }]];
        }
        if (cell.canOperate) {
            @weakify(self);
            [leftActionsArr addObject:[MGSwipeButton buttonWithTitle:nil
                                                                icon:[[UIImage imageNamed:@"action-info"] imageByTintColor:[UIColor whiteColor]]
                                                     backgroundColor:[STYLE_TINT_COLOR colorWithAlphaComponent:.6f]
                                                              insets:UIEdgeInsetsMake(0, 24, 0, 24)
                                                            callback:^BOOL(MGSwipeTableCell *sender) {
                                                                @strongify(self);
                                                                XXSwipeableCell *currentCell = (XXSwipeableCell *)sender;
                                                                [self setEditing:NO animated:YES];
                                                                UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:kXXItemAttributesTableViewControllerStoryboardID];
                                                                XXItemAttributesTableViewController *viewController = (XXItemAttributesTableViewController *)navController.topViewController;
                                                                viewController.currentPath = currentCell.itemAttrs[kXXItemPathKey];
                                                                [self.navigationController presentViewController:navController animated:YES completion:nil];
                                                                return YES;
                                                            }]];
        }
        if (cell.canOperate) {
            @weakify(self);
            [rightActionsArr addObject:[MGSwipeButton buttonWithTitle:nil
                                                                 icon:[[UIImage imageNamed:@"action-trash"] imageByTintColor:[UIColor whiteColor]]
                                                      backgroundColor:[UIColor colorWithRed:229.f/255.0f green:0.f/255.0f blue:15.f/255.0f alpha:1.f]
                                                               insets:UIEdgeInsetsMake(0, 24, 0, 24)
                                                             callback:^BOOL(MGSwipeTableCell *sender) {
                                                                 @strongify(self);
                                                                 [self setEditing:NO animated:YES];
                                                                 XXSwipeableCell *currentCell = (XXSwipeableCell *)sender;
                                                                 NSIndexPath *currentIndexPath = [self.tableView indexPathForCell:currentCell];
                                                                 SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete Confirm", nil)
                                                                                                                  andMessage:[NSString stringWithFormat:NSLocalizedString(@"Delete %@?\nThis operation cannot be revoked.", nil), currentCell.itemAttrs[kXXItemNameKey]]];
                                                                 [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alert) {
                                                                     
                                                                 }];
                                                                 [alertView addButtonWithTitle:NSLocalizedString(@"Yes", nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alert) {
                                                                     self.navigationController.view.userInteractionEnabled = NO;
                                                                     [self.navigationController.view makeToastActivity:CSToastPositionCenter];
                                                                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                                                         NSError *err = nil;
                                                                         BOOL result = [FCFileManager removeItemAtPath:currentCell.itemAttrs[kXXItemPathKey] error:&err]; // This may be time comsuming
                                                                         if (currentCell.checked) {
                                                                             if (_selectBootscript) {
                                                                                 [[XXLocalDataService sharedInstance] setStartUpConfigScriptPath:nil];
                                                                             } else {
                                                                                 [[XXLocalDataService sharedInstance] setSelectedScript:nil];
                                                                             }
                                                                         }
                                                                         dispatch_async_on_main_queue(^{
                                                                             self.navigationController.view.userInteractionEnabled = YES;
                                                                             [self.navigationController.view hideToastActivity];
                                                                             if (result && err == nil) {
                                                                                 [self reloadScriptListTableData];
                                                                                 [self.tableView beginUpdates];
                                                                                 [self.tableView deleteRowAtIndexPath:currentIndexPath withRowAnimation:UITableViewRowAnimationFade];
                                                                                 [self.tableView endUpdates];
                                                                             } else {
                                                                                 [self.navigationController.view makeToast:[err localizedDescription]];
                                                                             }
                                                                         });
                                                                     });
                                                                 }];
                                                                 [alertView show];
                                                                 return YES;
                                                             }]];
        }
        cell.rightButtons = rightActionsArr;
        cell.leftButtons = leftActionsArr;
    }
    
    return cell;
}

#pragma mark - Long Press Gesture for Block

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (_selectBootscript) {
        return NO;
    }
    return (self.isEditing == NO);
}

- (void)cellLongPress:(UIGestureRecognizer *)recognizer {
    if (self.isEditing == NO && recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [recognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        if (indexPath.section == 0 && indexPath.row == 0 && self.isRootDirectory && self.hidesMainPath == NO) {
            XXSwipeableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell becomeFirstResponder];
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            UIMenuItem *hideItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Hide", nil) action:@selector(hideItemTapped:)];
            [menuController setMenuItems:[NSArray arrayWithObjects:hideItem, nil]];
            [menuController setTargetRect:[self.tableView rectForRowAtIndexPath:indexPath] inView:self.tableView];
            [menuController setMenuVisible:YES animated:YES];
            return;
        }
        [self setEditing:YES animated:YES];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        self.topToolbar.pasteButton.enabled =
        self.topToolbar.shareButton.enabled =
        self.topToolbar.compressButton.enabled =
        self.topToolbar.trashButton.enabled = YES;
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(hideItemTapped:)) {
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

- (void)hideItemTapped:(id)sender {
    if (self.isRootDirectory && self.hidesMainPath == NO) {
        NSMutableDictionary *dict = [[XXLocalDataService sharedInstance] localUserConfig];
        [dict setObject:@YES forKey:kXXLocalConfigHidesMainPath];
        [[XXLocalDataService sharedInstance] setLocalUserConfig:dict];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        [self.navigationController.view makeToast:NSLocalizedString(@"\"Home Directory\" has been disabled, you can make it display again in \"More > User Defaults\".", nil)];
    }
}

#pragma mark - Table View Controller Editing Control

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    if (_selectBootscript) return;
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

- (void)popToSelectViewController {
    [self.navigationController popToViewController:self.selectViewController animated:YES];
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

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (self.isEditing) return NO;
    if ([identifier isEqualToString:kXXRewindSegueIdentifier]) {
        XXSwipeableCell *currentCell = (XXSwipeableCell *)sender;
        if (currentCell.isSelectable) return NO;
        if (!currentCell.isDirectory) return NO;
        return YES;
    }
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    XXSwipeableCell *currentCell = (XXSwipeableCell *)sender;
    if ([segue.identifier isEqualToString:kXXRewindSegueIdentifier]) {
        XXScriptListTableViewController *newController = (XXScriptListTableViewController *)segue.destinationViewController;
        newController.currentDirectory = currentCell.itemAttrs[kXXItemPathKey];
        if (_selectBootscript) {
            newController.selectBootscript = self.selectBootscript;
            newController.selectViewController = self.selectViewController;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEditing) {
        self.topToolbar.pasteButton.enabled =
        self.topToolbar.shareButton.enabled =
        self.topToolbar.compressButton.enabled =
        self.topToolbar.trashButton.enabled = YES;
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // It is OK if the last cell is not in display cuz the lastCell may be nil and nothing will happen if a message be sent to the nil
    XXSwipeableCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (currentCell.isSelectable) {
        if (!currentCell.checked) {
            XXSwipeableCell *lastCell = nil;
            for (XXSwipeableCell *cell in tableView.visibleCells) {
                if (cell.checked) {
                    lastCell = cell;
                }
            }
            if (_selectBootscript) {
                SendConfigAction([XXLocalNetService localSetSelectedStartUpScript:currentCell.itemAttrs[kXXItemPathKey] error:&err], lastCell.checked = NO; currentCell.checked = YES;  [self popToSelectViewController];);
            } else {
                SendConfigAction([XXLocalNetService localSetSelectedScript:currentCell.itemAttrs[kXXItemPathKey] error:&err], lastCell.checked = NO; currentCell.checked = YES;);
            }
        }
    } else {
        if (currentCell.isDirectory) {
            // Perform Segue
        } else {
            if (_selectBootscript) {
                [self.navigationController.view makeToast:NSLocalizedString(@"You can only select executable script type: lua, xxt", nil)];
            } else {
                BOOL result = [XXQuickLookService viewFileWithStandardViewer:currentCell.itemAttrs[kXXItemPathKey]
                                                        parentViewController:self];
                if (!result) {
                    result = [XXArchiveService unArchiveZip:currentCell.itemAttrs[kXXItemPathKey]
                                                toDirectory:self.currentDirectory
                                       parentViewController:self];
                }
                if (!result) {
                    [self.navigationController.view makeToast:NSLocalizedString(@"Unsupported file type", nil)];
                }
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectBootscript) {
        return NO;
    }
    if (indexPath.section == 0 && indexPath.row == 0 && self.isRootDirectory && self.hidesMainPath == NO) {
        return NO;
    }
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0 && self.isEditing && self.isRootDirectory && self.hidesMainPath == NO) {
        return nil;
    }
    return indexPath;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Replaced by MGSwipeTableCell
    return nil;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    XXSwipeableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell showSwipe:MGSwipeDirectionLeftToRight animated:YES];
}

#pragma mark - Actions

- (void)itemCountLabelTapped:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.currentDirectory];
    [self.navigationController.view makeToast:NSLocalizedString(@"Absolute path copied to the clipboard", nil)];
}

- (void)toolbarButtonTapped:(UIBarButtonItem *)sender {
    if (sender == self.topToolbar.scanButton) {
        [((XXNavigationViewController *)self.navigationController) transitionToScanViewController];
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
        NSMutableArray *pasteArr = [[XXLocalDataService sharedInstance] pasteboardArr];
        if (pasteArr.count != 0) {
            if (pasteArr.count == 1) {
                pasteStr = NSLocalizedString(@"Paste 1 item", nil);
                linkStr = NSLocalizedString(@"Create 1 link", nil);
            } else {
                pasteStr = [NSString stringWithFormat:NSLocalizedString(@"Paste %d items", nil), pasteArr.count];
                linkStr = [NSString stringWithFormat:NSLocalizedString(@"Create %d links", nil), pasteArr.count];
            }
            kXXPasteboardType pasteboardType = [[XXLocalDataService sharedInstance] pasteboardType];
            @weakify(self);
            [alertView addButtonWithTitle:pasteStr type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                @strongify(self);
                NSString *currentPath = self.currentDirectory;
                self.navigationController.view.userInteractionEnabled = NO;
                [self.navigationController.view makeToastActivity:CSToastPositionCenter];
                if (pasteboardType == kXXPasteboardTypeCut) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        NSError *err = nil;
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
                        NSError *err = nil;
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
                    NSError *err = nil;
                    NSString *currentPath = self.currentDirectory;
                    NSFileManager *fileManager = [[NSFileManager alloc] init];
                    for (NSString *originPath in pasteArr) {
                        NSString *destPath = [currentPath stringByAppendingPathComponent:[originPath lastPathComponent]];
                        [fileManager createSymbolicLinkAtPath:destPath withDestinationPath:originPath error:&err];
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
            NSMutableArray <NSString *> *selectedPaths = [[NSMutableArray alloc] init];
            for (NSIndexPath *path in selectedIndexes) {
                [selectedPaths addObject:self.rootItemsDictionaryArr[path.row][kXXItemPathKey]];
            }
            if (selectedIndexes.count == 1) {
                copyStr = NSLocalizedString(@"Copy 1 item", nil);
                cutStr = NSLocalizedString(@"Cut 1 item", nil);
            } else {
                copyStr = [NSString stringWithFormat:NSLocalizedString(@"Copy %d items", nil), selectedIndexes.count];
                cutStr = [NSString stringWithFormat:NSLocalizedString(@"Cut %d items", nil), selectedIndexes.count];
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
        
        [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
            
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
        NSArray <NSIndexPath *> *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
        
        NSString *formatString = nil;
        if (selectedIndexPaths.count == 1) {
            formatString = [NSString stringWithFormat:NSLocalizedString(@"Delete 1 item?\nThis operation cannot be revoked.", nil)];
        } else {
            formatString = [NSString stringWithFormat:NSLocalizedString(@"Delete %d items?\nThis operation cannot be revoked.", nil), selectedIndexPaths.count];
        }
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete Confirm", nil)
                                                         andMessage:formatString];
        @weakify(self);
        [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
            
        }];
        [alertView addButtonWithTitle:NSLocalizedString(@"Yes", nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
            @strongify(self);
            BOOL result = YES;
            NSError *err = nil;
            for (NSIndexPath *indexPath in selectedIndexPaths) {
                NSString *itemPath = self.rootItemsDictionaryArr[indexPath.row][kXXItemPathKey];
                if (_selectBootscript) {
                    if ([itemPath isEqualToString:[[XXLocalDataService sharedInstance] startUpConfigScriptPath]]) {
                        [[XXLocalDataService sharedInstance] setStartUpConfigScriptPath:nil];
                    }
                } else {
                    if ([itemPath isEqualToString:[[XXLocalDataService sharedInstance] selectedScript]]) {
                        [[XXLocalDataService sharedInstance] setSelectedScript:nil];
                    }
                }
                result = [FCFileManager removeItemAtPath:itemPath error:&err];
                if (err || !result) {
                    break;
                }
            }
            if (result) {
                [self.tableView beginUpdates];
                [self reloadScriptListTableData];
                [self.tableView deleteRowsAtIndexPaths:selectedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            } else {
                [self.navigationController.view makeToast:[err localizedDescription]];
            }
            [self setEditing:NO animated:YES];
        }];
        [alertView show];
    } else if (sender == self.topToolbar.shareButton) {
        NSArray <NSIndexPath *> *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
        NSMutableArray <NSURL *> *pathsArr = [[NSMutableArray alloc] init];
        for (NSIndexPath *indexPath in selectedIndexPaths) {
            NSDictionary *infoDict = self.rootItemsDictionaryArr[indexPath.row];
            if (![infoDict[NSFileType] isEqualToString:NSFileTypeDirectory]) {
                [pathsArr addObject:[NSURL fileURLWithPath:infoDict[kXXItemPathKey]]];
            }
        }
        if (pathsArr.count != 0) {
            BOOL didPresentOpenIn = NO;
            if (pathsArr.count == 1) {
                self.documentController.URL = pathsArr[0];
                didPresentOpenIn = [self.documentController presentOpenInMenuFromBarButtonItem:sender animated:YES];
            }
            if (!didPresentOpenIn || pathsArr.count > 1) {
                UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:pathsArr applicationActivities:nil];
                [self.navigationController presentViewController:controller animated:YES completion:nil];
            }
        } else {
            [self.navigationController.view makeToast:NSLocalizedString(@"You cannot share directory", nil)];
        }
    } else if (sender == self.topToolbar.compressButton) {
        NSArray <NSIndexPath *> *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
        NSString *formatString = nil;
        if (selectedIndexPaths.count == 1) {
            formatString = [NSString stringWithFormat:NSLocalizedString(@"Compress 1 item?", nil)];
        } else {
            formatString = [NSString stringWithFormat:NSLocalizedString(@"Compress %d items?", nil), selectedIndexPaths.count];
        }
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Archive Confirm", nil)
                                                         andMessage:formatString];
        @weakify(self);
        [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
            
        }];
        [alertView addButtonWithTitle:NSLocalizedString(@"Yes", nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
            @strongify(self);
            if (self.isEditing) {
                [self setEditing:NO animated:YES];
            }
            NSMutableArray <NSString *> *pathsArr = [[NSMutableArray alloc] init];
            for (NSIndexPath *indexPath in selectedIndexPaths) {
                NSString *itemPath = self.rootItemsDictionaryArr[indexPath.row][kXXItemPathKey];
                [pathsArr addObject:itemPath];
            }
            if (pathsArr.count != 0) {
                [XXArchiveService archiveItems:pathsArr
                                   toDirectory:self.currentDirectory
                          parentViewController:self];
            }
        }];
        [alertView show];
    }
}

#pragma mark - DocumentInteractionController

- (UIDocumentInteractionController *)documentController {
    if (!_documentController) {
        UIDocumentInteractionController *documentController = [[UIDocumentInteractionController alloc] init];
        _documentController = documentController;
    }
    return _documentController;
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

#pragma mark - Getter

- (BOOL)isRootDirectory {
    return (self != self.navigationController.topViewController && self.navigationController.topViewController != nil);
}

#pragma mark - Memory

- (void)dealloc {
    CYLog(@"");
}

@end
