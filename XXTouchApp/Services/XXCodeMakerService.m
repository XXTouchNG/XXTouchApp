//
//  XXCodeMakerService.m
//  XXTouchApp
//
//  Created by Zheng on 9/27/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXCodeMakerService.h"
#import "XXCodeBlocksViewController.h"
#import "NSString+CountSubstr.h"

#import "XXPickerBaseViewController.h"
#import "XXApplicationListTableViewController.h"
#import "XXKeyEventTableViewController.h"
#import "XXLocationPickerController.h"
#import "XXRectPickerController.h"
#import "XXPositionPickerController.h"
#import "XXColorPickerController.h"
#import "XXPosColorPickerController.h"
#import "XXMulPosColorPickerController.h"

@implementation XXCodeMakerService

+ (NSArray *)pickers {
    return @[
             [XXApplicationListTableViewController class],
             [XXKeyEventTableViewController class],
             [XXLocationPickerController class],
             [XXRectPickerController class],
             [XXPositionPickerController class],
             [XXColorPickerController class],
             [XXPosColorPickerController class],
             [XXMulPosColorPickerController class],
             ];
}

+ (void)pushToMakerWithCodeBlockModel:(XXCodeBlockModel *)model controller:(UIViewController *)controller {
    NSString *code = model.code;
    UINavigationController *navController = controller.navigationController;
    
    NSUInteger keywordCount = 0;
    NSUInteger location = 0;
    NSUInteger oldLocation = NSNotFound;
    
    Class pickerClass;
    
    for (Class cls in [self pickers]) {
        NSString *keyword = [cls keyword];
        if ((location = [code rangeOfString:keyword].location) != NSNotFound) {
            if (location <= oldLocation) {
                oldLocation = location;
                pickerClass = cls;
            }
            keywordCount += [code occurenceOfString:keyword];
        }
    }
    
    XXPickerBaseViewController *vc = nil;
    if ([pickerClass storyboardID] == nil) {
        vc = [[pickerClass alloc] init];
    } else {
        vc = [[UIStoryboard storyboardWithName:[pickerClass storyboardName] bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:[pickerClass storyboardID]];
    }
    
    if (vc != nil && keywordCount != 0) {
        vc.codeBlock = [model mutableCopy];
        XXCodeBlockModel *codeBlock = vc.codeBlock;
        codeBlock.totalStep = keywordCount + codeBlock.currentStep;
        [navController pushViewController:vc animated:YES];
    } else {
        model.code = [model.code stringByReplacingOccurrencesOfString:@"\\@" withString:@"@"];
        XXCodeBlocksViewController *codeBlockController = (XXCodeBlocksViewController *)navController.viewControllers[0];
        [codeBlockController replaceTextInputSelectedRangeWithModel:model];
        [navController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
