//
//  XXCodeMakerService.m
//  XXTouchApp
//
//  Created by Zheng on 9/27/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXCodeMakerService.h"
#import "XXApplicationListTableViewController.h"
#import "XXCodeBlocksViewController.h"
#import "XXKeyEventTableViewController.h"
#import "XXLocationPickerController.h"
#import "XXRectPickerController.h"
#import "NSString+countSubstr.h"

#define KEYWORD_BUNDLE_ID @"@bid@"
#define KEYWORD_KEY_EVENT @"@key@"
#define KEYWORD_LOCATION @"@loc@"
#define KEYWORD_RECTANGLE @"@rect@"

@implementation XXCodeMakerService

+ (void)pushToMakerWithCodeBlockModel:(XXCodeBlockModel *)model controller:(UIViewController *)controller {
    NSString *code = model.code;
    
    NSUInteger keywordCount = 0;
    UIViewController <XXPickerController> *vc = nil;
    if ([code containsString:KEYWORD_BUNDLE_ID]) {
        if (!vc) {
            vc = [controller.storyboard instantiateViewControllerWithIdentifier:kXXApplicationListTableViewControllerStoryboardID];
            vc.keyword = KEYWORD_BUNDLE_ID;
        }
        
        keywordCount += [code occurenceOfString:KEYWORD_BUNDLE_ID];
    }
    if ([code containsString:KEYWORD_KEY_EVENT]) {
        if (!vc) {
            vc = [controller.storyboard instantiateViewControllerWithIdentifier:kXXKeyEventTableViewControllerStoryboardID];
            vc.keyword = KEYWORD_KEY_EVENT;
        }
        keywordCount += [code occurenceOfString:KEYWORD_KEY_EVENT];
    }
    if ([code containsString:KEYWORD_LOCATION]) {
        if (!vc) {
            vc = [controller.storyboard instantiateViewControllerWithIdentifier:kXXLocationPickerControllerStoryboardID];
            vc.keyword = KEYWORD_LOCATION;
        }
        keywordCount += [code occurenceOfString:KEYWORD_LOCATION];
    }
    if ([code containsString:KEYWORD_RECTANGLE]) {
        if (!vc) {
            vc = [[XXRectPickerController alloc] init];
            vc.keyword = KEYWORD_RECTANGLE;
        }
        keywordCount += [code occurenceOfString:KEYWORD_RECTANGLE];
    }
    
    if (vc != nil && keywordCount != 0) {
        vc.codeBlock = [model mutableCopy]; // Copy
        
        XXCodeBlockModel *codeBlock = vc.codeBlock;
        codeBlock.totalStep = keywordCount + codeBlock.currentStep;
        
        [controller.navigationController pushViewController:vc animated:YES];
    } else {
        model.code = [model.code stringByReplacingOccurrencesOfString:@"\\@" withString:@"@"]; // unescape
        XXCodeBlocksViewController *codeBlockController = (XXCodeBlocksViewController *)controller.navigationController.viewControllers[0]; // Root View Controller
        [codeBlockController replaceTextInputSelectedRangeWithModel:model]; // replace
        [controller.navigationController dismissViewControllerAnimated:YES completion:nil]; // dismiss
    }
}

@end
