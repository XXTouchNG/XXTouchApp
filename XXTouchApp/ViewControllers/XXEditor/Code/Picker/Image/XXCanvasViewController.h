//
//  XXCanvasViewController.h
//  XXTouchApp
//
//  Created by Zheng on 18/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PECropView.h"
#import "XXPickerBaseViewController.h"

static NSString * const kXXLocalizedStringKeyTitle = @"kXXLocalizedStringKeyTitle";
static NSString * const kXXLocalizedStringKeyErrorLoadFile = @"kXXLocalizedStringKeyErrorLoadFile";
static NSString * const kXXLocalizedStringKeySelectImage = @"kXXLocalizedStringKeySelectImage";
static NSString * const kXXLocalizedStringKeySelected = @"kXXLocalizedStringKeySelected";
static NSString * const kXXLocalizedStringKeyEnterFull = @"kXXLocalizedStringKeyEnterFull";
static NSString * const kXXLocalizedStringKeyExitFull = @"kXXLocalizedStringKeyExitFull";
static NSString * const kXXLocalizedStringKeyCanvasLocked = @"kXXLocalizedStringKeyCanvasLocked";
static NSString * const kXXLocalizedStringKeyCanvasUnlocked = @"kXXLocalizedStringKeyCanvasUnlocked";
static NSString * const kXXLocalizedStringKeyErrorDeleteFile = @"kXXLocalizedStringKeyErrorDeleteFile";

@interface XXCanvasViewController : XXPickerBaseViewController

@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *localizedStrings;
@property (nonatomic, strong) PECropView *cropView;
- (kPECropViewType)cropViewType;

@end
