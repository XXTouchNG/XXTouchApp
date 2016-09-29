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

static NSString * const kXXCodeBlocksTableViewCellReuseIdentifier = @"kXXCodeBlocksTableViewCellReuseIdentifier";
static NSString * const kXXCodeBlocksTableViewInternalCellReuseIdentifier = @"kXXCodeBlocksTableViewInternalCellReuseIdentifier";
static NSString * const kXXCodeBlocksAddBlockSegueIdentifier = @"kXXCodeBlocksAddBlockSegueIdentifier";
static NSString * const kXXCodeBlocksEditBlockSegueIdentifier = @"kXXCodeBlocksEditBlockSegueIdentifier";

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
@property (nonatomic, assign) BOOL edited;

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
    
    self.tableView.contentInset =
    self.tableView.scrollIndicatorInsets =
    UIEdgeInsetsMake(0, 0, self.toolbar.height, 0);
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.segmentedControl setSelectedSegmentIndex:[[XXLocalDataService sharedInstance] selectedCodeBlockSegmentIndex]];
    [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:kXXCodeBlocksInternalFunctionSection];
    
    self.toolbar.hidden = (self.segmentedControl.selectedSegmentIndex != kXXCodeBlocksUserDefinedSection);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    if (editing) {
        
    } else {
        self.trashItem.enabled = NO;
        
        if (_edited) {
            _edited = NO;
            // Save to Database
            [[XXLocalDataService sharedInstance] setCodeBlockInternalFunctions:self.internalFunctions];
            [[XXLocalDataService sharedInstance] setCodeBlockUserDefinedFunctions:self.userDefinedFunctions];
        }
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

- (NSMutableArray <XXCodeBlockModel *> *)internalFunctions {
    return [[XXLocalDataService sharedInstance] codeBlockInternalFunctions];
}

- (NSMutableArray <XXCodeBlockModel *> *)userDefinedFunctions {
    return [[XXLocalDataService sharedInstance] codeBlockUserDefinedFunctions];
}

#pragma mark - Text replacing

- (void)replaceTextInputSelectedRangeWithModel:(XXCodeBlockModel *)model {
    UITextRange *selectedRange = [_textInput selectedTextRange];
    [_textInput replaceRange:selectedRange withText:model.code];
    
    if (model.offset != -1) {
        UITextPosition *insertPos = [_textInput positionFromPosition:selectedRange.start offset:model.offset];
        
        UITextPosition *beginPos = [_textInput beginningOfDocument];
        UITextPosition *startPos = [_textInput positionFromPosition:beginPos offset:[_textInput offsetFromPosition:beginPos toPosition:insertPos]];
        UITextRange *textRange = [_textInput textRangeFromPosition:startPos toPosition:startPos];
        [_textInput setSelectedTextRange:textRange];
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
    if (tableView == self.tableView) {
        return YES;
    }
    
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        return YES;
    }
    
    return NO;
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
                _edited = YES;
                [self.userDefinedFunctions removeObjectAtIndex:indexPath.row];
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
            cell.codeBlock = self.internalFunctions[indexPath.row];
            cell.textLabel.text = self.internalFunctions[indexPath.row].title;
        } else {
            cell.codeBlock = self.showInternalFunctions[indexPath.row];
            cell.textLabel.text = self.showInternalFunctions[indexPath.row].title;
        }
        
        return cell;
    } else if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
        XXCodeBlockTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kXXCodeBlocksTableViewCellReuseIdentifier forIndexPath:indexPath];
        if (tableView == self.tableView) {
            cell.codeBlock = self.userDefinedFunctions[indexPath.row];
            cell.textLabel.text = self.userDefinedFunctions[indexPath.row].title;
        } else {
            cell.codeBlock = self.showUserDefinedFunctions[indexPath.row];
            cell.textLabel.text = self.showUserDefinedFunctions[indexPath.row].title;
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
            [XXCodeMakerService pushToMakerWithCodeBlockModel:self.internalFunctions[indexPath.row] controller:self];
        } else if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
            [XXCodeMakerService pushToMakerWithCodeBlockModel:self.userDefinedFunctions[indexPath.row] controller:self];
        }
    } else {
        if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksInternalFunctionSection) {
            [XXCodeMakerService pushToMakerWithCodeBlockModel:self.showInternalFunctions[indexPath.row] controller:self];
        } else if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
            [XXCodeMakerService pushToMakerWithCodeBlockModel:self.showUserDefinedFunctions[indexPath.row] controller:self];
        }
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (tableView == self.tableView) {
        _edited = YES;
        if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksInternalFunctionSection) {
            [self.internalFunctions exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        } else if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
            [self.userDefinedFunctions exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
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
    [[XXLocalDataService sharedInstance] setSelectedCodeBlockSegmentIndex:sender.selectedSegmentIndex];
    if (sender.selectedSegmentIndex == kXXCodeBlocksInternalFunctionSection) {
        [self.toolbar setHidden:YES];
    } else if (sender.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
        [self.toolbar setHidden:NO];
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
        self->_edited = YES;
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        for (NSIndexPath *indexPath in indexPaths) {
            [indexSet addIndex:indexPath.row];
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
    if ([segue.identifier isEqualToString:kXXCodeBlocksEditBlockSegueIdentifier]) {
        ((XXAddCodeBlockTableViewController *)segue.destinationViewController).codeBlock = sender.codeBlock;
        ((XXAddCodeBlockTableViewController *)segue.destinationViewController).editMode = YES;
    } else if ([segue.identifier isEqualToString:kXXCodeBlocksAddBlockSegueIdentifier]) {
        if ([self isEditing]) {
            [self setEditing:NO animated:YES];
        }
    }
}

- (void)dealloc {
    CYLog(@"");
}

@end
