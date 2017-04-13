//
//  XXCreateItemTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/2/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXCreateItemTableViewController.h"
#import "XXLocalDataService.h"

typedef enum : NSUInteger {
    kXXCreateItemTypeRegularLuaFile = 0,
    kXXCreateItemTypeRegulatTextFile,
    kXXCreateItemTypeDirectory,
} kXXCreateItemType;

@interface XXCreateItemTableViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *itemNameTextField;
@property (nonatomic, assign) kXXCreateItemType selectedType;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end

@implementation XXCreateItemTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    self.itemNameTextField.delegate = self;
}

- (IBAction)nameTextFieldChanged:(UITextField *)sender {
    NSString *itemName = sender.text;
    if (itemName.length == 0 || itemName.length > 255) {
        self.doneButton.enabled = NO;
    } else self.doneButton.enabled = ![itemName containsString:@"/"];
}

- (IBAction)cancel:(id)sender {
    if ([self.itemNameTextField isFirstResponder]) {
        [self.itemNameTextField resignFirstResponder];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    NSString *itemName = _itemNameTextField.text;
    if (itemName.length == 0) {
        [self.navigationController.view makeToast:NSLocalizedString(@"Item name cannot be empty", nil)];
        return;
    } else if ([itemName containsString:@"/"]) {
        [self.navigationController.view makeToast:NSLocalizedString(@"Invalid item name", nil)];
        return;
    }
    BOOL result = NO;
    NSError *err = nil;
    kXXCreateItemType itemType = self.selectedType;
    NSString *itemPath = [self.currentDirectory stringByAppendingPathComponent:itemName];
    if (itemType == kXXCreateItemTypeRegularLuaFile) {
        itemPath = [itemPath stringByAppendingPathExtension:@"lua"];
        NSString *deviceName = [[UIDevice currentDevice] name];
        NSString *versionString = nil;
        if (daemonInstalled()) {
            versionString = [NSString stringWithFormat:@"%@ V%@", NSLocalizedString(@"XXTouch Pro", nil), extendDict()[@"DAEMON_VERSION"]];
        } else {
            versionString = [NSString stringWithFormat:@"%@ V%@ (%@)", NSLocalizedString(@"XXTouch", nil), VERSION_STRING, VERSION_BUILD];
        }
        NSString *newLua = [NSString stringWithFormat:@"--\n--  %@\n--  %@\n--\n--  Created by %@ on %@.\n--  Copyright © %ld %@.\n--  All rights reserved.\n--\n\n",
                            [itemName stringByAppendingPathExtension:@"lua"],
                            versionString,
                            deviceName,
                            [[[XXLocalDataService sharedInstance] miniDateFormatter] stringFromDate:[NSDate date]],
                            (long)[[NSDate date] year], deviceName];
        
        result = [newLua writeToFile:itemPath atomically:YES encoding:NSUTF8StringEncoding error:&err];
    } else if (itemType == kXXCreateItemTypeRegulatTextFile) {
        itemPath = [itemPath stringByAppendingPathExtension:@"txt"];
        NSString *newTxt = @"";
        result = [newTxt writeToFile:itemPath atomically:YES encoding:NSUTF8StringEncoding error:&err];
    } else if (itemType == kXXCreateItemTypeDirectory) {
        result = [[NSFileManager defaultManager] createDirectoryAtPath:itemPath withIntermediateDirectories:YES attributes:nil error:&err];
    }
    if (result) {
        if ([self.itemNameTextField isFirstResponder]) {
            [self.itemNameTextField resignFirstResponder];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (err != nil) {
        [self.navigationController.view makeToast:[err localizedDescription]];
    } else {
        [self.navigationController.view makeToast:NSLocalizedString(@"Unknown error", nil)];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![_itemNameTextField isFirstResponder]) {
        [_itemNameTextField becomeFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

// Static Cells
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        NSIndexPath *oldPath = [NSIndexPath indexPathForRow:self.selectedType inSection:1];
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectedType = (kXXCreateItemType) indexPath.row;
    }
}

- (void)dealloc {
    CYLog(@"");
}

@end
