//
//  XXAddCodeBlockTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/28/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXAddCodeBlockTableViewController.h"
#import "XXLocalDataService.h"

@interface XXAddCodeBlockTableViewController () <UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *codeTextView;

@end

@implementation XXAddCodeBlockTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (XXTPickerTask *)pickerTask {
    if (!_pickerTask) {
        _pickerTask = [XXTPickerTask taskWithTitle:@"" code:@""];
    }
    return _pickerTask;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titleField.text = self.pickerTask.title;
    _codeTextView.text = self.pickerTask.code;
    
    _titleField.delegate = self;
    _codeTextView.delegate = self;
    
    self.automaticallyAdjustsScrollViewInsets = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _titleField) {
        if ([textField isFirstResponder]) {
            [_codeTextView becomeFirstResponder];
        }
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)done:(UIBarButtonItem *)sender {
    if (_titleField.text.length <= 0 || _codeTextView.text.length <= 0) {
        [self.navigationController.view makeToast:NSLocalizedString(@"You should fill each blank before tap here.", nil)];
        return;
    }
    
    if ([_titleField isFirstResponder]) {
        [_titleField resignFirstResponder];
    }
    
    self.pickerTask.title = _titleField.text;
    self.pickerTask.code = _codeTextView.text;
    
    if (!_editMode) { // Add New Block
        [self.pickerTasks insertObject:self.pickerTask atIndex:0];
    }
    
    [self saveUserDefinedFunctions];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveUserDefinedFunctions {
    [XXTGSSI.dataService setObject:self.pickerTasks
                            forKey:kXXStorageKeyCodeBlockUserDefinedFunctions];
}

@end
