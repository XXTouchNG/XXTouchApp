//
//  XXCodeBlocksViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/25/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXCodeBlockTableViewCell.h"
#import "XXCodeBlocksViewController.h"
#import "XXAddCodeBlockTableViewController.h"
#import "XXTPickerCollection.h"

static NSString * const kXXCodeBlocksTableViewCellReuseIdentifier = @"kXXCodeBlocksTableViewCellReuseIdentifier";
static NSString * const kXXCodeBlocksTableViewInternalCellReuseIdentifier = @"kXXCodeBlocksTableViewInternalCellReuseIdentifier";
static NSString * const kXXCodeBlocksAddBlockSegueIdentifier = @"kXXCodeBlocksAddBlockSegueIdentifier";
static NSString * const kXXCodeBlocksEditBlockSegueIdentifier = @"kXXCodeBlocksEditBlockSegueIdentifier";

static NSString * const kXXStorageKeySelectedCodeBlockSegmentIndex = @"kXXStorageKeySelectedCodeBlockSegmentIndex";

enum {
    kXXCodeBlocksInternalFunctionSection = 0,
    kXXCodeBlocksUserDefinedSection,
};

@interface XXCodeBlocksViewController () <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic, strong) NSMutableArray <XXTPickerTask *> *internalFunctions;
@property (nonatomic, strong) NSMutableArray <XXTPickerTask *> *userDefinedFunctions;
@property (nonatomic, strong) NSArray <XXTPickerTask *> *showInternalFunctions;
@property (nonatomic, strong) NSArray <XXTPickerTask *> *showUserDefinedFunctions;

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
    
    [self.tableView setContentOffset:CGPointMake(0, self.searchDisplayController.searchBar.bounds.size.height)];
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
    // Save when exit
    [self saveInternalFunctions:self.internalFunctions];
    [self saveUserDefinedFunctions:self.userDefinedFunctions];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getters

- (NSUInteger)selectedCodeBlockSegmentIndex {
    return [(NSNumber *)[XXTGSSI.dataService objectForKey:kXXStorageKeySelectedCodeBlockSegmentIndex] unsignedIntegerValue];
}

- (void)setSelectedCodeBlockSegmentIndex:(NSUInteger)selectedCodeBlockSegmentIndex {
    [XXTGSSI.dataService setObject:@(selectedCodeBlockSegmentIndex) forKey:kXXStorageKeySelectedCodeBlockSegmentIndex];
}

- (NSMutableArray <XXTPickerTask *> *)internalFunctions {
    if (!_internalFunctions) {
        NSArray *plistArr = extendDict()[@"INTERNAL_FUNC"];
        NSMutableArray <XXTPickerTask *> *mModelArr = [NSMutableArray new];
        for (NSDictionary *m in plistArr)
        {
            [mModelArr addObject:[XXTPickerTask taskWithTitle:m[@"title"] code:m[@"code"]  udid:m[@"udid"]]];
        }
        
        BOOL edited = NO;
        NSMutableArray <XXTPickerTask *> *internalFunctions = (NSMutableArray <XXTPickerTask *> *)[XXTGSSI.dataService objectForKey:kXXStorageKeyCodeBlockInternalFunctions];
        if (!internalFunctions) {
            internalFunctions = mModelArr;
            edited = YES;
        } else {
            for (XXTPickerTask *aModel in mModelArr)
            {
                BOOL finded = NO;
                for (XXTPickerTask *bModel in internalFunctions) {
                    if ([bModel.udid isEqualToString:aModel.udid]) {
                        bModel.title = aModel.title;
                        bModel.code = aModel.code;
                        finded = YES;
                        break;
                    }
                }
                if (!finded) {
                    [internalFunctions insertObject:aModel atIndex:0];
                    edited = YES;
                }
            }
        }
        if (edited) {
            [XXTGSSI.dataService setObject:internalFunctions
                                                    forKey:kXXStorageKeyCodeBlockInternalFunctions];
        }
        
        _internalFunctions = internalFunctions;
    }
    return _internalFunctions;
}

- (void)saveInternalFunctions:(NSMutableArray<XXTPickerTask *> *)internalFunctions {
    [XXTGSSI.dataService setObject:internalFunctions
                            forKey:kXXStorageKeyCodeBlockInternalFunctions];
}

- (NSMutableArray <XXTPickerTask *> *)userDefinedFunctions {
    if (!_userDefinedFunctions) {
        NSArray *plistArr = extendDict()[@"USER_FUNC"];
        NSMutableArray <XXTPickerTask *> *mModelArr = [NSMutableArray new];
        for (NSDictionary *m in plistArr)
        {
            [mModelArr addObject:[XXTPickerTask taskWithTitle:m[@"title"] code:m[@"code"]  udid:m[@"udid"]]];
        }
        
        BOOL edited = NO;
        NSMutableArray <XXTPickerTask *> *userDefinedFunctions = (NSMutableArray <XXTPickerTask *> *)[XXTGSSI.dataService objectForKey:kXXStorageKeyCodeBlockUserDefinedFunctions];
        if (!userDefinedFunctions) {
            userDefinedFunctions = mModelArr;
            edited = YES;
        } else {
            for (XXTPickerTask *aModel in mModelArr)
            {
                BOOL finded = NO;
                for (XXTPickerTask *bModel in userDefinedFunctions) {
                    if ([bModel.udid isEqualToString:aModel.udid]) {
                        bModel.title = aModel.title;
                        bModel.code = aModel.code;
                        finded = YES;
                        break;
                    }
                }
                if (!finded) {
                    [userDefinedFunctions insertObject:aModel atIndex:0];
                    edited = YES;
                }
            }
        }
        if (edited) {
            [XXTGSSI.dataService setObject:userDefinedFunctions
                                    forKey:kXXStorageKeyCodeBlockUserDefinedFunctions];
        }
        
        _userDefinedFunctions = userDefinedFunctions;
    }
    return _userDefinedFunctions;
}

- (void)saveUserDefinedFunctions:(NSMutableArray<XXTPickerTask *> *)userDefinedFunctions {
    [XXTGSSI.dataService setObject:userDefinedFunctions
                            forKey:kXXStorageKeyCodeBlockUserDefinedFunctions];
}

#pragma mark - Text replacing

- (void)finishTask:(XXTPickerTask *)task {
    [self replaceTextInputSelectedRangeWithModel:task];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)replaceTextInputSelectedRangeWithModel:(XXTPickerTask *)model {
    NSRange selectedNSRange = _textInput.selectedRange;
    UITextRange *selectedRange = [_textInput selectedTextRange];
    
    NSString *stringRef = _textInput.text;
    NSRange lastBreak = [stringRef rangeOfString:@"\n" options:NSBackwardsSearch range:NSMakeRange(0, selectedNSRange.location)];
    
    NSUInteger idx = lastBreak.location + 1;
    
    BOOL autoIndent = YES;
    if (lastBreak.location == NSNotFound) {
        idx = 0;
    }
    else if (lastBreak.location + lastBreak.length == selectedNSRange.location) {
        autoIndent = NO;
    }
    
    NSString *replaceCode = nil;
    if (autoIndent) {
        NSMutableString *tabStr = [NSMutableString new];
        [tabStr appendString:@"\n"];
        for (; idx < selectedNSRange.location; idx++) {
            char thisChar = (char) [stringRef characterAtIndex:idx];
            if (thisChar != ' ' && thisChar != '\t') break;
            else [tabStr appendFormat:@"%c", (char)thisChar];
        }
        NSMutableString *mutableCode = [model.code mutableCopy];
        [mutableCode replaceOccurrencesOfString:@"\n"
                                     withString:tabStr
                                        options:NSCaseInsensitiveSearch
                                          range:NSMakeRange(0, mutableCode.length)];
        replaceCode = [mutableCode copy];
    } else {
        replaceCode = [model.code copy];
    }
    [_textInput replaceRange:selectedRange withText:replaceCode];
    
    NSRange modelCurPos = [replaceCode rangeOfString:@"@@"];
    if (modelCurPos.location != NSNotFound) {
        NSRange curPos = NSMakeRange(
                                     selectedNSRange.location
                                     + modelCurPos.location, 2
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
            cell.pickerTask = self.internalFunctions[(NSUInteger) indexPath.row];
            cell.textLabel.text = self.internalFunctions[(NSUInteger) indexPath.row].title;
        } else {
            cell.pickerTask = self.showInternalFunctions[(NSUInteger) indexPath.row];
            cell.textLabel.text = self.showInternalFunctions[(NSUInteger) indexPath.row].title;
        }
        
        return cell;
    } else if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
        XXCodeBlockTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kXXCodeBlocksTableViewCellReuseIdentifier forIndexPath:indexPath];
        if (tableView == self.tableView) {
            cell.pickerTask = self.userDefinedFunctions[(NSUInteger) indexPath.row];
            cell.textLabel.text = self.userDefinedFunctions[(NSUInteger) indexPath.row].title;
        } else {
            cell.pickerTask = self.showUserDefinedFunctions[(NSUInteger) indexPath.row];
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
    XXTPickerTask *pickerTask = nil;
    if (tableView == self.tableView) {
        if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksInternalFunctionSection) {
            pickerTask = self.internalFunctions[(NSUInteger) indexPath.row];
        } else if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
            pickerTask = self.userDefinedFunctions[(NSUInteger) indexPath.row];
        }
    } else {
        if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksInternalFunctionSection) {
            pickerTask = self.showInternalFunctions[(NSUInteger) indexPath.row];
        } else if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
            pickerTask = self.showUserDefinedFunctions[(NSUInteger) indexPath.row];
        }
    }
    if (pickerTask) {
        
        id nextPicker = [[pickerTask nextStepClass] new];
        if (nextPicker && [nextPicker respondsToSelector:@selector(setPickerTask:)])
        {
            [nextPicker performSelector:@selector(setPickerTask:) withObject:[pickerTask mutableCopy]];
        }
        
        if (nextPicker) {
            [[XXTPickerHelper sharedInstance] setCallbackObject:self];
            [[XXTPickerHelper sharedInstance] setCallbackSelector:@selector(finishTask:)];
            [self.navigationController pushViewController:nextPicker animated:YES];
        } else {
            [self replaceTextInputSelectedRangeWithModel:pickerTask];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
//    self.navigationController.navigationBar.translucent = YES;
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

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
//    self.navigationController.navigationBar.translucent = NO;
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
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
        
    }];
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
        addController.pickerTask = sender.pickerTask;
        addController.pickerTasks = self.userDefinedFunctions;
        addController.editMode = YES;
    } else if ([segue.identifier isEqualToString:kXXCodeBlocksAddBlockSegueIdentifier]) {
        addController.pickerTask = nil;
        addController.pickerTasks = self.userDefinedFunctions;
        addController.editMode = NO;
        if ([self isEditing]) {
            [self setEditing:NO animated:YES];
        }
    }
}

- (void)dealloc {
    XXLog(@"");
}

@end
