//
//  XXEditorFontSettingsTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 01/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXEditorFontSettingsTableViewController.h"
#import "XXLocalDataService.h"

@interface XXEditorFontSettingsTableViewController ()
@property (nonatomic, assign) NSUInteger selectedIndex;

@end

@implementation XXEditorFontSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadFontSettings];
}

// Static Cells
- (void)displayCheckmarkForIndexPath:(NSIndexPath *)indexPath {
    for (int i = 0; i <= [self.tableView numberOfRowsInSection:indexPath.section]; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
        if (i == indexPath.row) {
            _selectedIndex = i;
            cell.textLabel.textColor = STYLE_TINT_COLOR;
            if (cell.accessoryType != UITableViewCellAccessoryCheckmark) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        } else {
            cell.textLabel.textColor = [UIColor blackColor];
            if (cell.accessoryType != UITableViewCellAccessoryNone) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    [self.tableView reloadData];
}

- (void)loadFontSettings {
    _selectedIndex = [XXTGSSI.dataService fontFamily];
    [self displayCheckmarkForIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_selectedIndex != indexPath.row && indexPath.section == 0) {
        [XXTGSSI.dataService setFontFamily:indexPath.row];
        [self notifyChanged];
        [self loadFontSettings];
    }
}

- (void)notifyChanged {
    if (_delegate && [_delegate respondsToSelector:@selector(editorFontSettingsDidEdited:)])
    {
        [_delegate editorFontSettingsDidEdited:self];
    }
}

- (void)dealloc {
    XXLog(@"");
}

@end
