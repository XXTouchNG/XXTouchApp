//
//  XXMixedPickerController.m
//  XXTouchApp
//
//  Created by Zheng on 10/10/16.
//  Copyright (c) 2016 Zheng. All rights reserved.
//

#import "XXMixedPickerController.h"
#import "XXImagePickerController.h"
#import "XXImagePickerPlaceholderView.h"
#import "XXCodeMakerService.h"

@interface XXMixedPickerController () <DoImagePickerControllerDelegate>
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) XXImagePickerPlaceholderView *placeholderView;

@property (nonatomic, strong) UIBarButtonItem *nextButton;
@property (nonatomic, copy) NSString *keyword;

@end

@implementation XXMixedPickerController {

}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (_pickerType == kXXImagePickerTypePosition) {
        self.title = NSLocalizedString(@"Position", nil);
        self.keyword = @"@pos@";
    } else if (_pickerType == kXXImagePickerTypeColor) {
        self.title = NSLocalizedString(@"Color", nil);
        self.keyword = @"@color@";
    } else if (_pickerType == kXXImagePickerTypeMixed) {
        self.title = NSLocalizedString(@"Mixed", nil);
        self.keyword = @"@poscolor@";
    }
    [self.view addSubview:self.placeholderView];
    
    if (_codeBlock) {
        self.navigationItem.rightBarButtonItem = self.nextButton;
    }
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

#pragma mark - Getter

- (XXImagePickerPlaceholderView *)placeholderView {
    if (!_placeholderView) {
        _placeholderView = [[XXImagePickerPlaceholderView alloc] initWithFrame:self.view.bounds];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(placeholderViewTapped:)];
        [_placeholderView addGestureRecognizer:tapGesture];
    }
    return _placeholderView;
}

- (UIBarButtonItem *)nextButton {
    if (!_nextButton) {
        UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Skip", nil) style:UIBarButtonItemStylePlain target:self action:@selector(next:)];
        nextButton.tintColor = [UIColor whiteColor];
        _nextButton = nextButton;
    }
    return _nextButton;
}

- (void)next:(UIBarButtonItem *)sender {
    [self pushToNextControllerWithKeyword:self.keyword replacement:@""];
}

- (void)pushToNextControllerWithKeyword:(NSString *)keyword
                            replacement:(NSString *)replace {
    XXCodeBlockModel *newBlock = [_codeBlock mutableCopy];
    NSString *code = newBlock.code;
    NSRange range = [code rangeOfString:keyword];
    if (range.length == 0) return;
    newBlock.code = [code stringByReplacingCharactersInRange:range withString:replace];
    [XXCodeMakerService pushToMakerWithCodeBlockModel:newBlock controller:self];
}

#pragma mark - Tap Gesture

- (void)placeholderViewTapped:(UITapGestureRecognizer *)sender {
    XXImagePickerController *cont = [[XXImagePickerController alloc] initWithNibName:@"XXImagePickerController" bundle:nil];
    cont.delegate = self;
    cont.nResultType = DO_PICKER_RESULT_ASSET;
    cont.nMaxCount = 1;
    cont.nColumnCount = 4;
    [self presentViewController:cont animated:YES completion:nil];
}

#pragma mark - DoImagePickerControllerDelegate

- (void)didCancelDoImagePickerController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectPhotosFromDoImagePickerController:(XXImagePickerController *)picker
                                            result:(NSArray *)aSelected
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
