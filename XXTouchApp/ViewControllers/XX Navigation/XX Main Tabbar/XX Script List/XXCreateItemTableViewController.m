//
//  XXCreateItemTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/2/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXCreateItemTableViewController.h"

typedef enum : NSUInteger {
    kXXCreateItemTypeRegularLuaFile = 0,
    kXXCreateItemTypeRegulatTextFile,
    kXXCreateItemTypeDirectory,
} kXXCreateItemType;

@interface XXCreateItemTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *itemNameTextField;
@property (nonatomic, assign) kXXCreateItemType selectedType;

@end

@implementation XXCreateItemTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CYLog(@"%@", self.currentDirectory);
}

- (IBAction)done:(id)sender {
    NSString *itemName = _itemNameTextField.text;
    if (itemName.length == 0) {
        [self.navigationController.view makeToast:NSLocalizedStringFromTable(@"Name cannot be empty.", @"XXTouch", nil)];
        return;
    }
    NSError *err = nil;
    kXXCreateItemType itemType = self.selectedType;
    NSString *itemPath = [self.currentDirectory stringByAppendingPathComponent:itemName];
    if (itemType == kXXCreateItemTypeRegularLuaFile) {
        itemPath = [itemPath stringByAppendingPathExtension:@"lua"];
        [FCFileManager createFileAtPath:itemPath error:&err];
    } else if (itemType == kXXCreateItemTypeRegulatTextFile) {
        itemPath = [itemPath stringByAppendingPathExtension:@"txt"];
        [FCFileManager createFileAtPath:itemPath error:&err];
    } else if (itemType == kXXCreateItemTypeDirectory) {
        [FCFileManager createDirectoriesForPath:itemPath error:&err];
    }
    if (err == nil) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController.view makeToast:[err localizedDescription]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_itemNameTextField becomeFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        NSIndexPath *oldPath = [NSIndexPath indexPathForRow:self.selectedType inSection:1];
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectedType = indexPath.row;
    }
}

@end
