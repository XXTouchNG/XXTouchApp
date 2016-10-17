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

- (XXCodeBlockModel *)codeBlock {
    if (!_codeBlock) {
        _codeBlock = [XXCodeBlockModel modelWithTitle:@"" code:@""];
    }
    return _codeBlock;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titleField.text = self.codeBlock.title;
    _codeTextView.text = self.codeBlock.code;
    
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
    
    self.codeBlock.title = _titleField.text;
    self.codeBlock.code = _codeTextView.text;
    
    if (!_editMode) { // Add New Block
        [self.codeBlocks insertObject:self.codeBlock atIndex:0];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
