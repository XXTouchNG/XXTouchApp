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

@implementation XXCodeMakerService

+ (void)pushToMakerWithCodeBlockModel:(XXCodeBlockModel *)model controller:(UIViewController *)controller {
    NSString *code = model.code;
    if ([code containsString:@"@bid@"]) {
        XXApplicationListTableViewController *vc = [controller.storyboard instantiateViewControllerWithIdentifier:kXXApplicationListTableViewControllerStoryboardID];
        vc.codeBlock = [model mutableCopy]; // Copy
        [controller.navigationController pushViewController:vc animated:YES];
    } else if ([code containsString:@"@key@"]) {
        XXKeyEventTableViewController *vc = [controller.storyboard instantiateViewControllerWithIdentifier:kXXKeyEventTableViewControllerStoryboardID];
        vc.codeBlock = [model mutableCopy]; // Copy
        [controller.navigationController pushViewController:vc animated:YES];
    } else if ([code containsString:@"@loc@"]) {
        XXKeyEventTableViewController *vc = [controller.storyboard instantiateViewControllerWithIdentifier:kXXLocationPickerControllerStoryboardID];
        vc.codeBlock = [model mutableCopy]; // Copy
        [controller.navigationController pushViewController:vc animated:YES];
    } else {
        model.code = [model.code stringByReplacingOccurrencesOfString:@"\\@" withString:@"@"]; // unescape
        XXCodeBlocksViewController *codeBlockController = (XXCodeBlocksViewController *)controller.navigationController.viewControllers[0]; // Root View Controller
        [codeBlockController replaceTextInputSelectedRangeWithModel:model];
        [controller.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
