//
//  XXCodeBlocksViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/25/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXCodeBlockModel.h"
#import "XXCodeBlocksViewController.h"
#import "XXApplicationListTableViewController.h"
#import "XXCodeMakerService.h"

static NSString * const kXXCodeBlocksTableViewCellReuseIdentifier = @"kXXCodeBlocksTableViewCellReuseIdentifier";
static NSString * const kXXCodeBlocksTableViewInternalCellReuseIdentifier = @"kXXCodeBlocksTableViewInternalCellReuseIdentifier";

enum {
    kXXCodeBlocksInternalFunctionSection = 0,
    kXXCodeBlocksUserDefinedSection,
};

@interface XXCodeBlocksViewController () <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic, strong) NSArray <XXCodeBlockModel *> *internalFunctions;
@property (nonatomic, strong) NSArray <XXCodeBlockModel *> *userDefinedFunctions;
@property (nonatomic, strong) NSArray <XXCodeBlockModel *> *showInternalFunctions;
@property (nonatomic, strong) NSArray <XXCodeBlockModel *> *showUserDefinedFunctions;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

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
    
    self.navigationItem.rightBarButtonItem = nil;
    self.toolbar.hidden = YES;
    [self.segmentedControl setSelectedSegmentIndex:kXXCodeBlocksInternalFunctionSection];
    [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:kXXCodeBlocksInternalFunctionSection];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    if (editing) {
        
    } else {
        self.trashItem.enabled = NO;
    }
}

- (IBAction)close:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getters

- (NSArray <XXCodeBlockModel *> *)internalFunctions {
    if (!_internalFunctions) {
        _internalFunctions = @[
                               [XXCodeBlockModel modelWithTitle:@"touch.tap(x, y)" code:@"touch.tap(@pos@)"],
                               [XXCodeBlockModel modelWithTitle:@"touch.on(x, y):move(x1, y1)" code:@"touch.on(@pos@):move(@pos@)"],
                               [XXCodeBlockModel modelWithTitle:@"screen.ocr_text(left, top, right, bottom)" code:@"screen.ocr_text(@pos@, @pos@)"],
                               [XXCodeBlockModel modelWithTitle:@"screen.is_colors(colors, similarity)" code:@"screen.is_colors(@poscolors@, @slider@)"],
                               [XXCodeBlockModel modelWithTitle:@"screen.find_color(colors, similarity)" code:@"screen.find_color(@poscolors@, @slider@)"],
                               [XXCodeBlockModel modelWithTitle:@"key.press(key)" code:@"key.press(@key@)"],
                               [XXCodeBlockModel modelWithTitle:@"app.run(bid)" code:@"app.run(\"@bid@\")"],
                               [XXCodeBlockModel modelWithTitle:@"app.close(bid)" code:@"app.close(\"@bid@\")"],
                               [XXCodeBlockModel modelWithTitle:@"app.quit(bid)" code:@"app.quit(\"@bid@\")"],
                               [XXCodeBlockModel modelWithTitle:@"app.bundle_path(bid)" code:@"app.bundle_path(\"@bid@\")"],
                               [XXCodeBlockModel modelWithTitle:@"app.data_path(bid)" code:@"app.data_path(\"@bid@\")"],
                               [XXCodeBlockModel modelWithTitle:@"app.is_running(bid)" code:@"app.is_running(\"@bid@\")"],
                               [XXCodeBlockModel modelWithTitle:@"app.is_front(bid)" code:@"app.is_front(\"@bid@\")"],
                               [XXCodeBlockModel modelWithTitle:@"app.uninstall(bid)" code:@"app.uninstall(\"@bid@\")"],
                               [XXCodeBlockModel modelWithTitle:@"clear.keychain(bid)" code:@"clear.keychain(\"@bid@\")"],
                               [XXCodeBlockModel modelWithTitle:@"clear.app_data(bid)" code:@"clear.app_data(\"@bid@\")"],
                               ];
    }
    return _internalFunctions;
}

#pragma mark - Text replacing

- (void)replaceTextInputSelectedRangeWithString:(NSString *)string {
    [_textInput replaceRange:[_textInput selectedTextRange] withText:string];
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
        if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksInternalFunctionSection) {
            return NO;
        } else if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksInternalFunctionSection) {
            return NO;
        } else if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
            return YES;
        }
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
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (self.isEditing) {
        return;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksInternalFunctionSection) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kXXCodeBlocksTableViewInternalCellReuseIdentifier forIndexPath:indexPath];
        if (tableView == self.tableView) {
            cell.textLabel.text = self.internalFunctions[indexPath.row].title;
        } else {
            cell.textLabel.text = self.showInternalFunctions[indexPath.row].title;
        }
        
        return cell;
    } else if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kXXCodeBlocksTableViewCellReuseIdentifier forIndexPath:indexPath];
        if (tableView == self.tableView) {
            cell.textLabel.text = self.userDefinedFunctions[indexPath.row].title;
        } else {
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
    if (self.isEditing && _segmentedControl.selectedSegmentIndex != kXXCodeBlocksInternalFunctionSection) {
        self.trashItem.enabled = YES;
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.tableView) {
        if (_segmentedControl.selectedSegmentIndex == kXXCodeBlocksInternalFunctionSection) {
            [XXCodeMakerService pushToMakerWithCodeBlockModel:self.internalFunctions[indexPath.row] controller:self];
        } else if (indexPath.section == kXXCodeBlocksUserDefinedSection) {
            [XXCodeMakerService pushToMakerWithCodeBlockModel:self.userDefinedFunctions[indexPath.row] controller:self];
        }
    } else {
        if (indexPath.section == kXXCodeBlocksInternalFunctionSection) {
            [XXCodeMakerService pushToMakerWithCodeBlockModel:self.showInternalFunctions[indexPath.row] controller:self];
        } else if (indexPath.section == kXXCodeBlocksUserDefinedSection) {
            [XXCodeMakerService pushToMakerWithCodeBlockModel:self.showUserDefinedFunctions[indexPath.row] controller:self];
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        return sourceIndexPath;
    }
    
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
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
    [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:sender.selectedSegmentIndex];
    if (sender.selectedSegmentIndex == kXXCodeBlocksInternalFunctionSection) {
        [self.toolbar setHidden:YES];
        self.navigationItem.rightBarButtonItem = nil;
    } else if (sender.selectedSegmentIndex == kXXCodeBlocksUserDefinedSection) {
        [self.toolbar setHidden:NO];
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    [self.tableView reloadData];
}

- (void)dealloc {
    CYLog(@"");
}

@end
