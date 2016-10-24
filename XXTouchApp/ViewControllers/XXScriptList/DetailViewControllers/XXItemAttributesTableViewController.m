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
#import "NSString+Mime.h"

static char * const kXXTouchCalculatingDirectorySizeIdentifier = "com.xxtouch.calculating-directory-size";

@interface XXItemAttributesTableViewController () <UITextFieldDelegate>
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

@property (nonatomic, copy) NSString *originalName;
@property (nonatomic, copy) NSString *originalPath;

@property (nonatomic, strong) MJRefreshNormalHeader *refreshHeader;

@property (nonatomic, strong) NSDictionary *currentAttributes;

@end

@implementation XXItemAttributesTableViewController

int cancelFlag = 0;

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)cancel:(id)sender {
    if ([_nameTextField isFirstResponder]) {
        [_nameTextField resignFirstResponder];
    }
    [self dismissViewControllerAnimated:YES completion:^() {
        cancelFlag = 1;
    }];
}

- (IBAction)done:(id)sender {
    NSString *itemName = _nameTextField.text;
    if (itemName.length == 0) {
        [self.navigationController.view makeToast:NSLocalizedString(@"Item name cannot be empty", nil)];
        return;
    } else if ([itemName containsString:@"/"]) {
        [self.navigationController.view makeToast:NSLocalizedString(@"Invalid item name", nil)];
        return;
    }
    NSString *targetPath = [[self.originalPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:itemName];
    if ([FCFileManager existsItemAtPath:targetPath]) {
        [self.navigationController.view makeToast:[NSString stringWithFormat:NSLocalizedString(@"File \"%@\" already exists.", nil), itemName]];
        return;
    }
    NSError *err = nil;
    [FCFileManager moveItemAtPath:self.originalPath toPath:targetPath error:&err];
    if (err != nil) {
        [self.navigationController.view makeToast:[err localizedDescription]];
        return;
    }
    if ([_nameTextField isFirstResponder]) {
        [_nameTextField resignFirstResponder];
    }
    [self dismissViewControllerAnimated:YES completion:^() {
        cancelFlag = 1;
    }];
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
    cancelFlag = 0;
    self.clearsSelectionOnViewWillAppear = YES;
    self.nameTextField.delegate = self;
    self.tableView.mj_header = self.refreshHeader;
    [self reloadItemInfo];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (MJRefreshNormalHeader *)refreshHeader {
    if (!_refreshHeader) {
        MJRefreshNormalHeader *normalHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadItemInfo)];
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

- (void)reloadItemInfo {
    NSString *itemName = [self.currentPath lastPathComponent];
    self.nameTextField.text = itemName;
    self.originalName = [itemName mutableCopy];
    __block NSString *itemPath = self.currentPath;
    self.absolutePathDetailLabel.text = [itemPath mutableCopy];
    self.originalPath = itemPath;
    NSError *err = nil;
    self.currentAttributes = [FCFileManager attributesOfItemAtPath:itemPath error:&err];
    if (err != nil) {
        return;
    }
    NSString *itemType = [self.currentAttributes objectForKey:NSFileType];
    if (itemType == NSFileTypeDirectory) {
        self.itemTypeLabel.text = NSLocalizedString(@"Directory", nil);
        self.itemSizeLabel.text = NSLocalizedString(@"Calculating...", nil);
        @weakify(self);
        dispatch_queue_t concurrentQueue = dispatch_queue_create(kXXTouchCalculatingDirectorySizeIdentifier, DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(concurrentQueue, ^{
            NSString *formattedSize = [FCFileManager sizeFormattedOfDirectoryAtPath:itemPath cancelFlag:&cancelFlag];
            dispatch_async_on_main_queue(^{
                @strongify(self);
                self.itemSizeLabel.text = formattedSize;
            });
        });
    } else if (itemType == NSFileTypeRegular) {
        self.itemTypeLabel.text = NSLocalizedString(@"Regular File", nil);
        self.mimeTypeLabel.text = [itemPath mime];
        self.itemSizeLabel.text = [FCFileManager sizeFormattedOfItemAtPath:itemPath error:&err];
    } else if (itemType == NSFileTypeSymbolicLink) {
        self.itemTypeLabel.text = NSLocalizedString(@"Symbolic Link", nil);
        self.itemSizeLabel.text = [FCFileManager sizeFormattedOfItemAtPath:itemPath error:&err];
    } else {
        self.itemTypeLabel.text = NSLocalizedString(@"Unsupported file type", nil);
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
        [self.navigationController.view makeToast:NSLocalizedString(@"Absolute path copied to the clipboard", nil)];
    }
}

- (void)dealloc {
    CYLog(@"");
}

@end
