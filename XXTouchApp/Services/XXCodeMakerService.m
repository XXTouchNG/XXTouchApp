//
//  XXCodeMakerService.m
//  XXTouchApp
//
//  Created by Zheng on 9/27/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXCodeMakerService.h"
#import "XXPickerBaseViewController.h"
#import "XXApplicationListTableViewController.h"
#import "XXCodeBlocksViewController.h"
#import "XXKeyEventTableViewController.h"
#import "XXLocationPickerController.h"
#import "XXRectPickerController.h"
#import "XXPositionPickerController.h"
#import "XXColorPickerController.h"
#import "XXPosColorPickerController.h"
#import "NSString+countSubstr.h"

#define KEYWORD_BUNDLE_ID @"@bid@"
#define KEYWORD_KEY_EVENT @"@key@"
#define KEYWORD_LOCATION @"@loc@"
#define KEYWORD_RECTANGLE @"@rect@"
#define KEYWORD_POSITION @"@pos@"
#define KEYWORD_COLOR @"@color@"
#define KEYWORD_POSCOLOR @"@poscolor@"

typedef enum : NSUInteger {
    kXXPickerTypeNone = 0,
    kXXPickerTypeBID,
    kXXPickerTypeKEY,
    kXXPickerTypeLOC,
    kXXPickerTypeRECT,
    kXXPickerTypePOS,
    kXXPickerTypeCOLOR,
    kXXPickerTypePOSCOLOR
} kXXPickerType;

@implementation XXCodeMakerService

+ (void)pushToMakerWithCodeBlockModel:(XXCodeBlockModel *)model controller:(UIViewController *)controller {
    NSString *code = model.code;
    
    NSUInteger keywordCount = 0;
    NSUInteger location = 0;
    NSUInteger oldLocation = NSNotFound;
    kXXPickerType type = kXXPickerTypeNone;
    
    if ((location = [code rangeOfString:KEYWORD_BUNDLE_ID].location) != NSNotFound) {
        if (location <= oldLocation) {
            oldLocation = location;
            type = kXXPickerTypeBID;
        }
        keywordCount += [code occurenceOfString:KEYWORD_BUNDLE_ID];
    }
    if ((location = [code rangeOfString:KEYWORD_KEY_EVENT].location) != NSNotFound) {
        if (location <= oldLocation) {
            oldLocation = location;
            type = kXXPickerTypeKEY;
        }
        keywordCount += [code occurenceOfString:KEYWORD_KEY_EVENT];
    }
    if ((location = [code rangeOfString:KEYWORD_LOCATION].location) != NSNotFound) {
        if (location <= oldLocation) {
            oldLocation = location;
            type = kXXPickerTypeLOC;
        }
        keywordCount += [code occurenceOfString:KEYWORD_LOCATION];
    }
    if ((location = [code rangeOfString:KEYWORD_RECTANGLE].location) != NSNotFound) {
        if (location <= oldLocation) {
            oldLocation = location;
            type = kXXPickerTypeRECT;
        }
        keywordCount += [code occurenceOfString:KEYWORD_RECTANGLE];
    }
    if ((location = [code rangeOfString:KEYWORD_POSITION].location) != NSNotFound) {
        if (location <= oldLocation) {
            oldLocation = location;
            type = kXXPickerTypePOS;
        }
        keywordCount += [code occurenceOfString:KEYWORD_POSITION];
    }
    if ((location = [code rangeOfString:KEYWORD_COLOR].location) != NSNotFound) {
        if (location <= oldLocation) {
            oldLocation = location;
            type = kXXPickerTypeCOLOR;
        }
        keywordCount += [code occurenceOfString:KEYWORD_COLOR];
    }
    if ((location = [code rangeOfString:KEYWORD_POSCOLOR].location) != NSNotFound) {
        if (location <= oldLocation) {
            oldLocation = location;
            type = kXXPickerTypePOSCOLOR;
        }
        keywordCount += [code occurenceOfString:KEYWORD_POSCOLOR];
    }
    
    
    XXPickerBaseViewController *vc = nil;
    if (type == kXXPickerTypeBID) {
        vc = [controller.navigationController.storyboard instantiateViewControllerWithIdentifier:kXXApplicationListTableViewControllerStoryboardID];
        vc.keyword = KEYWORD_BUNDLE_ID;
    } else if (type == kXXPickerTypeKEY) {
        vc = [controller.navigationController.storyboard instantiateViewControllerWithIdentifier:kXXKeyEventTableViewControllerStoryboardID];
        vc.keyword = KEYWORD_KEY_EVENT;
    } else if (type == kXXPickerTypeLOC) {
        vc = [controller.navigationController.storyboard instantiateViewControllerWithIdentifier:kXXLocationPickerControllerStoryboardID];
        vc.keyword = KEYWORD_LOCATION;
    } else if (type == kXXPickerTypeRECT) {
        vc = [[XXRectPickerController alloc] init];
        vc.keyword = KEYWORD_RECTANGLE;
    } else if (type == kXXPickerTypePOS) {
        vc = [[XXPositionPickerController alloc] init];
        vc.keyword = KEYWORD_POSITION;
    } else if (type == kXXPickerTypeCOLOR) {
        vc = [[XXColorPickerController alloc] init];
        vc.keyword = KEYWORD_COLOR;
    } else if (type == kXXPickerTypePOSCOLOR) {
        vc = [[XXPosColorPickerController alloc] init];
        vc.keyword = KEYWORD_POSCOLOR;
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
