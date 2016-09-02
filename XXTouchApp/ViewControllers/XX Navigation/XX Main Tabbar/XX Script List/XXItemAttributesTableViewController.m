//
//  XXItemAttributesTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/2/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXItemAttributesTableViewController.h"
#import "XXLocalDataService.h"
#import <MJRefresh/MJRefresh.h>

@interface XXItemAttributesTableViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *absolutePathLabel;
@property (weak, nonatomic) IBOutlet UILabel *absolutePathDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *mimeTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifiedAtLabel;

@property (nonatomic, strong) NSString *originalName;
@property (nonatomic, strong) NSString *originalPath;

@property (nonatomic, strong) MJRefreshNormalHeader *refreshHeader;

@property (nonatomic, strong) NSDictionary *currentAttributes;

@end

@implementation XXItemAttributesTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)cancel:(id)sender {
    if ([_nameTextField isFirstResponder]) {
        [_nameTextField resignFirstResponder];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    NSString *itemName = _nameTextField.text;
    if (itemName.length == 0) {
        [self.navigationController.view makeToast:NSLocalizedStringFromTable(@"Item name cannot be empty.", @"XXTouch", nil)];
        return;
    } else if ([itemName containsString:@"/"]) {
        [self.navigationController.view makeToast:NSLocalizedStringFromTable(@"Invalid item name.", @"XXTouch", nil)];
        return;
    }
    NSError *err = nil;
    [FCFileManager renameItemAtPath:self.originalPath withName:itemName error:&err];
    if (err != nil) {
        [self.navigationController.view makeToast:[err localizedDescription]];
        return;
    }
    if ([_nameTextField isFirstResponder]) {
        [_nameTextField resignFirstResponder];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nameTextFieldChanged:(UITextField *)sender {
    NSString *itemName = sender.text;
    if (itemName.length == 0 || itemName.length > 255) {
        self.doneButton.enabled = NO;
    } else if ([itemName containsString:@"/"]) {
        self.doneButton.enabled = NO;
    } else if ([itemName isEqualToString:self.originalName]) {
        self.doneButton.enabled = NO;
    } else {
        self.doneButton.enabled = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.mj_header = self.refreshHeader;
    [self reloadItemInfo];
    {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        tapGesture.cancelsTouchesInView = NO;
        [self.view addGestureRecognizer:tapGesture];
    }
}

- (void)viewTapped:(UITapGestureRecognizer *)tapGesture {
    if ([_nameTextField isFirstResponder]) {
        [_nameTextField resignFirstResponder];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_nameTextField becomeFirstResponder];
}

- (MJRefreshNormalHeader *)refreshHeader {
    if (!_refreshHeader) {
        MJRefreshNormalHeader *normalHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadItemInfo)];
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

- (void)reloadItemInfo {
    NSError *err = nil;
    NSString *itemName = self.currentName;
    self.nameTextField.text = itemName;
    self.originalName = [itemName mutableCopy];
    NSString *itemPath = self.currentPath;
    self.absolutePathDetailLabel.text = [itemPath mutableCopy];
    self.originalPath = itemPath;
    self.currentAttributes = [FCFileManager attributesOfItemAtPath:itemPath error:&err];
    NSString *itemType = [self.currentAttributes objectForKey:NSFileType];
    if (itemType == NSFileTypeDirectory) {
        self.itemTypeLabel.text = NSLocalizedStringFromTable(@"Directory", @"XXTouch", nil);
        self.itemSizeLabel.text = NSLocalizedStringFromTable(@"Calculating...", @"XXTouch", nil);
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            weakSelf.itemSizeLabel.text = [FCFileManager sizeFormattedOfDirectoryAtPath:itemPath];
        });
    } else if (itemType == NSFileTypeRegular) {
        self.itemTypeLabel.text = NSLocalizedStringFromTable(@"Regular File", @"XXTouch", nil);
        self.mimeTypeLabel.text = [itemPath mime];
        self.itemSizeLabel.text = [FCFileManager sizeFormattedOfItemAtPath:itemPath error:&err];
    } else if (itemType == NSFileTypeSymbolicLink) {
        self.itemTypeLabel.text = NSLocalizedStringFromTable(@"Symbolic Link", @"XXTouch", nil);
        self.itemSizeLabel.text = [FCFileManager sizeFormattedOfItemAtPath:itemPath error:&err];
    } else {
        self.itemTypeLabel.text = NSLocalizedStringFromTable(@"Unsupported", @"XXTouch", nil);
    }
    NSDate *creationDate = [self.currentAttributes objectForKey:NSFileCreationDate];
    NSString *creationFormattedDate = [[[XXLocalDataService sharedInstance] defaultDateFormatter] stringFromDate:creationDate];
    self.createdAtLabel.text = creationFormattedDate;
    NSDate *modificationDate = [self.currentAttributes objectForKey:NSFileModificationDate];
    NSString *modificationFormattedDate = [[[XXLocalDataService sharedInstance] defaultDateFormatter] stringFromDate:modificationDate];
    self.modifiedAtLabel.text = modificationFormattedDate;
    if ([self.refreshHeader isRefreshing]) {
        [self.refreshHeader endRefreshing];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 1) {
        [[UIPasteboard generalPasteboard] setString:self.originalPath];
        [self.navigationController.view makeToast:NSLocalizedStringFromTable(@"The absolute path has been copied to the clipboard.", @"XXTouch", nil)];
    }
}

@end
