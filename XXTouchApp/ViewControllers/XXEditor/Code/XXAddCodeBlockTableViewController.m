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
@property (nonatomic, strong) NSMutableArray <XXCodeBlockModel *> *codeBlocks;
@property (weak, nonatomic) IBOutlet UITextField *offsetField;

@property (nonatomic, assign) BOOL edited;

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

- (NSMutableArray <XXCodeBlockModel *> *)codeBlocks {
    return [[XXLocalDataService sharedInstance] codeBlockUserDefinedFunctions];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titleField.text = self.codeBlock.title;
    _codeTextView.text = self.codeBlock.code;
    _offsetField.text = [NSString stringWithFormat:@"%ld", self.codeBlock.offset];
    
    _titleField.delegate = self;
    _codeTextView.delegate = self;
    _offsetField.delegate = self;
    
    self.automaticallyAdjustsScrollViewInsets = YES;
}

- (IBAction)titleFieldChanged:(UITextField *)sender {
    _edited = YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    _edited = YES;
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
    if (_offsetField.text.length == 0) {
        _offsetField.text = @"-1";
    }
    if (![_offsetField.text matchesRegex:@"^-?[0-9]\\d*$"
                                 options:0]) {
        [self.navigationController.view makeToast:NSLocalizedString(@"Invalid offset", nil)];
        return;
    }
    NSInteger testedInt = [_offsetField.text integerValue];
    if (testedInt != -1 && testedInt > _codeTextView.text.length) {
        [self.navigationController.view makeToast:NSLocalizedString(@"Offset out of range", nil)];
        return;
    }
    if ([_titleField isFirstResponder]) {
        [_titleField resignFirstResponder];
    }
    
    self.codeBlock.title = _titleField.text;
    self.codeBlock.code = _codeTextView.text;
    self.codeBlock.offset = testedInt;
    
    if (!_editMode) { // Add New Block
        [self.codeBlocks insertObject:self.codeBlock atIndex:0];
    }
    if (_edited) {
        // Save to Database
        [[XXLocalDataService sharedInstance] setCodeBlockUserDefinedFunctions:self.codeBlocks];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
