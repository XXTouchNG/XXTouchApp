//
//  XXCodeBlocksViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/25/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXCodeBlockTableViewCell.h"
#import "XXCodeBlocksViewController.h"
#import "XXApplicationListTableViewController.h"
#import "XXAddCodeBlockTableViewController.h"
#import "XXCodeMakerService.h"
#import "XXLocalDataService.h"

#define kXXInternalFunctionsVersion 37

static NSString * const kXXCodeBlocksTableViewCellReuseIdentifier = @"kXXCodeBlocksTableViewCellReuseIdentifier";
static NSString * const kXXCodeBlocksTableViewInternalCellReuseIdentifier = @"kXXCodeBlocksTableViewInternalCellReuseIdentifier";
static NSString * const kXXCodeBlocksAddBlockSegueIdentifier = @"kXXCodeBlocksAddBlockSegueIdentifier";
static NSString * const kXXCodeBlocksEditBlockSegueIdentifier = @"kXXCodeBlocksEditBlockSegueIdentifier";

static NSString * const kXXStorageKeySelectedCodeBlockSegmentIndex = @"kXXStorageKeySelectedCodeBlockSegmentIndex";
static NSString * const kXXStorageKeyCodeBlockInternalFunctions = @"kXXStorageKeyCodeBlockInternalFunctions-%@";
static NSString * const kXXStorageKeyCodeBlockUserDefinedFunctions = @"kXXStorageKeyCodeBlockUserDefinedFunctions";

enum {
    kXXCodeBlocksInternalFunctionSection = 0,
    kXXCodeBlocksUserDefinedSection,
};

@interface XXCodeBlocksViewController () <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic, strong) NSMutableArray <XXCodeBlockModel *> *internalFunctions;
@property (nonatomic, strong) NSMutableArray <XXCodeBlockModel *> *userDefinedFunctions;
@property (nonatomic, strong) NSArray <XXCodeBlockModel *> *showInternalFunctions;
@property (nonatomic, strong) NSArray <XXCodeBlockModel *> *showUserDefinedFunctions;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, assign) NSUInteger selectedCodeBlockSegmentIndex;

@end

@implementation XXCodeBlocksViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.searchDisplayController.active) {
        return UIStatusBarStyleDefault;
    }
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchDisplayController.delegate = self;
    
    self.tableView.allowsSelection = YES;
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.segmentedControl setSelectedSegmentIndex:[self selectedCodeBlockSegmentIndex]];
    [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:[self selectedCodeBlockSegmentIndex]];
    
    self.toolbar.hidden = (self.segmentedControl.selectedSegmentIndex != kXXCodeBlocksUserDefinedSection);
    if (self.toolbar.hidden) {
        self.tableView.contentInset =
        self.tableView.scrollIndicatorInsets =
        UIEdgeInsetsZero;
    } else {
        self.tableView.contentInset =
        self.tableView.scrollIndicatorInsets =
        UIEdgeInsetsMake(0, 0, self.toolbar.height, 0);
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    if (editing) {
        
    } else {
        self.trashItem.enabled = NO;
        [self saveInternalFunctions:self.internalFunctions];
        [self saveUserDefinedFunctions:self.userDefinedFunctions];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (IBAction)close:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getters

- (NSUInteger)selectedCodeBlockSegmentIndex {
    return [(NSNumber *)[[XXLocalDataService sharedInstance] objectForKey:kXXStorageKeySelectedCodeBlockSegmentIndex] unsignedIntegerValue];
}

- (void)setSelectedCodeBlockSegmentIndex:(NSUInteger)selectedCodeBlockSegmentIndex {
    [[XXLocalDataService sharedInstance] setObject:@(selectedCodeBlockSegmentIndex) forKey:kXXStorageKeySelectedCodeBlockSegmentIndex];
}

- (NSMutableArray <XXCodeBlockModel *> *)internalFunctions {
    if (!_internalFunctions) {
        NSMutableArray <XXCodeBlockModel *> *internalFunctions = (NSMutableArray <XXCodeBlockModel *> *)[[XXLocalDataService sharedInstance] objectForKey:[NSString stringWithFormat:kXXStorageKeyCodeBlockInternalFunctions, VERSION_BUILD]];
        if (!internalFunctions) {
            internalFunctions = [[NSMutableArray alloc] initWithArray:
@[
[XXCodeBlockModel modelWithTitle:@"touch.tap(x, y)" code:@"touch.tap(@pos@@cur@)"],
[XXCodeBlockModel modelWithTitle:@"touch.on(x, y):move(x1, y1)" code:@"touch.on(@pos@@cur@):move(@pos@)"],
[XXCodeBlockModel modelWithTitle:@"screen.ocr_text(left, top, right, bottom)" code:@"screen.ocr_text(@rect@@cur@)"],
[XXCodeBlockModel modelWithTitle:@"screen.is_colors(colors, similarity)" code:@"screen.is_colors(@poscolor@@cur@, @slider@)"],
[XXCodeBlockModel modelWithTitle:@"screen.find_color(colors, similarity)" code:@"screen.find_color(@poscolor@@cur@, @slider@)"],
[XXCodeBlockModel modelWithTitle:@"key.press(key)" code:@"key.press(\"@key@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"gps.fake(bid, latitude, longitude)" code:@"gps.fake(\"@bid@@cur@\", @loc@)"],
[XXCodeBlockModel modelWithTitle:@"gps.clear([bid])" code:@"gps.fake(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"app.run(bid)" code:@"app.run(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"app.close(bid)" code:@"app.close(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"app.quit(bid)" code:@"app.quit(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"app.bundle_path(bid)" code:@"app.bundle_path(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"app.data_path(bid)" code:@"app.data_path(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"app.is_running(bid)" code:@"app.is_running(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"app.is_front(bid)" code:@"app.is_front(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"app.uninstall(bid)" code:@"app.uninstall(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"clear.keychain(bid)" code:@"clear.keychain(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"clear.app_data(bid)" code:@"clear.app_data(\"@bid@@cur@\")"],
]
                                 ];
            [[XXLocalDataService sharedInstance] setObject:internalFunctions
                                                    forKey:[NSString stringWithFormat:kXXStorageKeyCodeBlockInternalFunctions, VERSION_BUILD]];
        }
        _internalFunctions = internalFunctions;
    }
    
    return _internalFunctions;
}

- (void)saveInternalFunctions:(NSMutableArray<XXCodeBlockModel *> *)internalFunctions {
    [[XXLocalDataService sharedInstance] setObject:internalFunctions
                                            forKey:[NSString stringWithFormat:kXXStorageKeyCodeBlockInternalFunctions, VERSION_BUILD]];
}

- (NSMutableArray <XXCodeBlockModel *> *)userDefinedFunctions {
    if (!_userDefinedFunctions) {
        NSMutableArray <XXCodeBlockModel *> * userDefinedFunctions = (NSMutableArray <XXCodeBlockModel *> *)[[XXLocalDataService sharedInstance] objectForKey:kXXStorageKeyCodeBlockUserDefinedFunctions];
        if (!userDefinedFunctions) {
            userDefinedFunctions = [[NSMutableArray alloc] initWithArray:
@[
[XXCodeBlockModel modelWithTitle:@"print()" code:@"print(@cur@)\n"],
[XXCodeBlockModel modelWithTitle:@"print.out()" code:@"print.out(@cur@)\n"],
[XXCodeBlockModel modelWithTitle:@"sys.toast(\"\")" code:@"sys.toast(\"@cur@\")\n"],
[XXCodeBlockModel modelWithTitle:@"sys.alert(\"\", 0)" code:@"sys.alert(\"@cur@\", 0)\n"],
[XXCodeBlockModel modelWithTitle:@"if ... then ... end" code:@"if () then\n\t@cur@\nend\n"],
[XXCodeBlockModel modelWithTitle:@"for i = 1, 10, 1 do ... end" code:@"for i = 1, 10, 1 do\n\t@cur@\nend\n"],
[XXCodeBlockModel modelWithTitle:@"while (true) do .. end" code:@"while (true) do\n\t@cur@\nend\n"],
[XXCodeBlockModel modelWithTitle:@"repeat ... until (false)" code:@"repeat\n\t@cur@\nuntil (false)\n"],
[XXCodeBlockModel modelWithTitle:@"sys.msleep(1000)" code:@"sys.msleep(1000@cur@)\n"],
[XXCodeBlockModel modelWithTitle:@"touch.tap(x, y)" code:@"touch.tap(x@cur@, y)\n"],
[XXCodeBlockModel modelWithTitle:@"app.input_text(\"\")" code:@"app.input_text(\"@cur@\")\n"],
[XXCodeBlockModel modelWithTitle:@"accelerometer.shake()" code:@"accelerometer.shake()\n"],
[XXCodeBlockModel modelWithTitle:@"r = sys.input_box(\"\")" code:@"r = sys.input_box(\"@cur@\")\n"],
[XXCodeBlockModel modelWithTitle:@"pasteboard.write(\"\")" code:@"pasteboard.write(\"@cur@\")\n"],
[XXCodeBlockModel modelWithTitle:@"r = pasteboard.read()" code:@"r = pasteboard.read()\n"],
[XXCodeBlockModel modelWithTitle:@"os.execute(\"\")" code:@"os.execute(\"@cur@\")\n"],
]
                                    ];
            [[XXLocalDataService sharedInstance] setObject:userDefinedFunctions
                                                    forKey:kXXStorageKeyCodeBlockUserDefinedFunctions];
        }
        
        _userDefinedFunctions = userDefinedFunctions;
    }
    return _userDefinedFunctions;
}

- (void)saveUserDefinedFunctions:(NSMutableArray<XXCodeBlockModel *> *)userDefinedFunctions {
    [[XXLocalDataService sharedInstance] setObject:userDefinedFunctions
                                            forKey:kXXStorageKeyCodeBlockUserDefinedFunctions];
}

#pragma mark - Text replacing

- (void)replaceTextInputSelectedRangeWithModel:(XXCodeBlockModel *)model {
    NSRange selectedNSRange = _textInput.selectedRange;
    UITextRange *selectedRange = [_textInput selectedTextRange];
    [_textInput replaceRange:selectedRange withText:model.code];
    
    NSRange modelCurPos = [model.code rangeOfString:@"@cur@"];
    if (modelCurPos.location != NSNotFound) {
        NSRange curPos = NSMakeRange(
                                     selectedNSRange.location
                                     + modelCurPos.location, 5
                                     );
        UITextPosition *insertPos = [_textInput positionFromPosition:selectedRange.start offset:curPos.location];
        
        UITextPosition *beginPos = [_textInput beginningOfDocument];
        UITextPosition *startPos = [_textInput positionFromPosition:beginPos offset:[_textInput offsetFromPosition:beginPos toPosition:insertPos]];
        UITextRange *textRange = [_textInput textRangeFromPosition:startPos toPosition:startPos];
        [_textInput setSelectedTextRange:textRange];
        
        UITextPosition *curBegin = [_textInput beginningOfDocument];
        UITextPosition *curStart = [_textInput positionFromPosition:curBegin offset:curPos.location];
        UITextPosition *curEnd = [_textInput positionFromPosition:curStart offset:curPos.length];
        UITextRange *curRange = [_textInput textRangeFromPosition:curStart toPosition:curEnd];
        [_textInput replaceRange:curRange withText:@""];
    }
    
    if (![_textInput isFirstResponder]) {
        [_textInput becomeFirstResponder];
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; // Segmented Control
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksInternalFunctionSection) {
            return self.internalFunctions.count;
        } else if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
            return self.userDefinedFunctions.count;
        }
    } else {
        if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksInternalFunctionSection) {
            return self.showInternalFunctions.count;
        } else if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
            return self.showUserDefinedFunctions.count;
        }
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksInternalFunctionSection) {
        return NSLocalizedString(@"Internal Functions", nil);
    } else if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
        return NSLocalizedString(@"User Defined", nil);
    }
    return @"";
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView == self.tableView;

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView == self.tableView;

}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
            return UITableViewCellEditingStyleDelete;
        }
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
                [self.userDefinedFunctions removeObjectAtIndex:(NSUInteger) indexPath.row];
                [tableView beginUpdates];
                [tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
                [tableView endUpdates];
                [self setEditing:NO animated:YES];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (self.isEditing) {
        return;
    }
    // Perform Segue
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksInternalFunctionSection) {
        XXCodeBlockTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kXXCodeBlocksTableViewInternalCellReuseIdentifier forIndexPath:indexPath];
        if (tableView == self.tableView) {
            cell.codeBlock = self.internalFunctions[(NSUInteger) indexPath.row];
            cell.textLabel.text = self.internalFunctions[(NSUInteger) indexPath.row].title;
        } else {
            cell.codeBlock = self.showInternalFunctions[(NSUInteger) indexPath.row];
            cell.textLabel.text = self.showInternalFunctions[(NSUInteger) indexPath.row].title;
        }
        
        return cell;
    } else if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
        XXCodeBlockTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kXXCodeBlocksTableViewCellReuseIdentifier forIndexPath:indexPath];
        if (tableView == self.tableView) {
            cell.codeBlock = self.userDefinedFunctions[(NSUInteger) indexPath.row];
            cell.textLabel.text = self.userDefinedFunctions[(NSUInteger) indexPath.row].title;
        } else {
            cell.codeBlock = self.showUserDefinedFunctions[(NSUInteger) indexPath.row];
            cell.textLabel.text = self.showUserDefinedFunctions[(NSUInteger) indexPath.row].title;
        }
        
        return cell;
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView indexPathsForSelectedRows].count == 0) {
        self.trashItem.enabled = NO;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEditing) {
        self.trashItem.enabled = YES;
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.tableView) {
        if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksInternalFunctionSection) {
            [XXCodeMakerService pushToMakerWithCodeBlockModel:self.internalFunctions[(NSUInteger) indexPath.row] controller:self];
        } else if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
            [XXCodeMakerService pushToMakerWithCodeBlockModel:self.userDefinedFunctions[(NSUInteger) indexPath.row] controller:self];
        }
    } else {
        if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksInternalFunctionSection) {
            [XXCodeMakerService pushToMakerWithCodeBlockModel:self.showInternalFunctions[(NSUInteger) indexPath.row] controller:self];
        } else if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
            [XXCodeMakerService pushToMakerWithCodeBlockModel:self.showUserDefinedFunctions[(NSUInteger) indexPath.row] controller:self];
        }
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (tableView == self.tableView) {
        if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksInternalFunctionSection) {
            [self.internalFunctions exchangeObjectAtIndex:(NSUInteger) sourceIndexPath.row withObjectAtIndex:(NSUInteger) destinationIndexPath.row];
        } else if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
            [self.userDefinedFunctions exchangeObjectAtIndex:(NSUInteger) sourceIndexPath.row withObjectAtIndex:(NSUInteger) destinationIndexPath.row];
        }
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
    [self.segmentedControl setSelectedSegmentIndex:searchOption];
    [self segmentedControlChanged:self.segmentedControl];
    [self.tableView reloadData];
    [self reloadSearch];
    return YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [self segmentedControlChanged:self.segmentedControl];
}

- (void)reloadSearch {
    NSString *searchText = self.searchDisplayController.searchBar.text;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title CONTAINS[cd] %@) OR (code CONTAINS[cd] %@)", searchText, searchText];
    if (predicate) {
        if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == kXXCodeBlocksInternalFunctionSection) {
            self.showInternalFunctions = [[NSArray alloc] initWithArray:[self.internalFunctions filteredArrayUsingPredicate:predicate]];
            self.showUserDefinedFunctions = @[];
        } else if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == kXXCodeBlocksUserDefinedSection) {
            self.showInternalFunctions = @[];
            self.showUserDefinedFunctions = [[NSArray alloc] initWithArray:[self.userDefinedFunctions filteredArrayUsingPredicate:predicate]];
        }
    }
}

#pragma mark - Segmented Control

- (IBAction)segmentedControlChanged:(UISegmentedControl *)sender {
    [self setEditing:NO animated:YES];
    [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:sender.selectedSegmentIndex];
    [self setSelectedCodeBlockSegmentIndex:sender.selectedSegmentIndex];
    if (sender.selectedSegmentIndex == kXXCodeBlocksInternalFunctionSection) {
        [self.toolbar setHidden:YES];
    } else if (sender.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
        [self.toolbar setHidden:NO];
    }
    if (!self.searchDisplayController.active) {
        if (self.toolbar.hidden) {
            self.tableView.contentInset =
            self.tableView.scrollIndicatorInsets =
            UIEdgeInsetsZero;
        } else {
            self.tableView.contentInset =
            self.tableView.scrollIndicatorInsets =
            UIEdgeInsetsMake(0, 0, self.toolbar.height, 0);
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Toolbar Actions

- (IBAction)trashButtonTapped:(UIBarButtonItem *)sender {
    if (self.searchDisplayController.active || self.segmentedControl.selectedSegmentIndex != kXXCodeBlocksUserDefinedSection) {
        return;
    }
    NSArray <NSIndexPath *> *indexPaths = [self.tableView indexPathsForSelectedRows];
    if (indexPaths.count == 0) {
        return;
    }
    NSString *messageStr = nil;
    if (indexPaths.count == 1) {
        messageStr = NSLocalizedString(@"Delete 1 item?", nil);
    } else {
        messageStr = [NSString stringWithFormat:NSLocalizedString(@"Delete %d items?", nil), indexPaths.count];
    }
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete Confirm", nil) andMessage:messageStr];
    @weakify(self);
    [alertView addButtonWithTitle:NSLocalizedString(@"Yes", nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        @strongify(self);
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        for (NSIndexPath *indexPath in indexPaths) {
            [indexSet addIndex:(NSUInteger) indexPath.row];
        }
        [self.userDefinedFunctions removeObjectsAtIndexes:indexSet];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        [self setEditing:NO animated:YES];
    }];
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
        
    }];
    [alertView show];
}

#pragma mark - Segue

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:kXXCodeBlocksEditBlockSegueIdentifier]) {
        if (self.editing || self.segmentedControl.selectedSegmentIndex != kXXCodeBlocksUserDefinedSection) {
            return NO;
        }
    } else if ([identifier isEqualToString:kXXCodeBlocksAddBlockSegueIdentifier]) {
        
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(XXCodeBlockTableViewCell *)sender {
    XXAddCodeBlockTableViewController *addController = ((XXAddCodeBlockTableViewController *)segue.destinationViewController);
    if ([segue.identifier isEqualToString:kXXCodeBlocksEditBlockSegueIdentifier]) {
        addController.codeBlock = sender.codeBlock;
        addController.codeBlocks = self.userDefinedFunctions;
        addController.editMode = YES;
    } else if ([segue.identifier isEqualToString:kXXCodeBlocksAddBlockSegueIdentifier]) {
        addController.codeBlock = nil;
        addController.codeBlocks = self.userDefinedFunctions;
        addController.editMode = NO;
        if ([self isEditing]) {
            [self setEditing:NO animated:YES];
        }
    }
}

- (void)dealloc {
    CYLog(@"");
}

@end
