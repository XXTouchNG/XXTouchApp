//
//  XXPosColorPickerController.m
//  XXTouchApp
//
//  Created by Zheng on 20/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXPosColorPickerController.h"

@interface XXPosColorPickerController ()

@end

@implementation XXPosColorPickerController

@synthesize localizedStrings = _localizedStrings;

- (kXXCropViewType)cropViewType {
    return kXXCropViewTypePositionColor;
}

- (NSDictionary <NSString *, NSString *> *)localizedStrings {
    if (!_localizedStrings) {
        _localizedStrings = @{ kXXLocalizedStringKeyTitle: NSLocalizedString(@"Position & Color", nil),
                               kXXLocalizedStringKeyErrorLoadFile: NSLocalizedString(@"Cannot load image from temporarily file", nil),
                               kXXLocalizedStringKeySelectImage: NSLocalizedString(@"Select an image from album", nil),
                               kXXLocalizedStringKeySelected: NSLocalizedString(@"Select a position by tapping on image", nil),
                               kXXLocalizedStringKeyEnterFull: NSLocalizedString(@"Triple touches to exit fullscreen", nil),
                               kXXLocalizedStringKeyExitFull: NSLocalizedString(@"One finger to drag, two fingers to zoom", nil),
                               kXXLocalizedStringKeyCanvasLocked: NSLocalizedString(@"Canvas locked, it cannot be moved or zoomed", nil),
                               kXXLocalizedStringKeyCanvasUnlocked: NSLocalizedString(@"Canvas unlocked", nil),
                               kXXLocalizedStringKeyErrorDeleteFile: NSLocalizedString(@"Cannot remove temporarily file", nil),
                               };
    }
    return _localizedStrings;
}

#pragma mark - Strings

- (NSString *)previewString {
    return [self stringFromPosColor:self.currentModel tips:NO];
}

#pragma mark - Points

- (NSString *)stringFromPosColor:(XXPositionColorModel *)poscolor tips:(BOOL)tips {
    UIColor *c = [poscolor.color copy];
    if (!c) {
        c = [UIColor blackColor];
    }
    CGPoint p = poscolor.position;
    NSString *pFormat = nil;
    if (tips) {
        pFormat = @"x = %d, y = %d (#%@)";
    } else {
        pFormat = @"%d, %d, 0x%@";
    }
    return [NSString stringWithFormat:pFormat, (int)p.x, (int)p.y, [c hexString]];
}

- (void)setCurrentModel:(XXPositionColorModel *)currentModel {
    _currentModel = currentModel;
    self.subtitle = [self stringFromPosColor:currentModel tips:YES];
}

#pragma mark - Memory

- (void)dealloc {
    CYLog(@"");
}

@end
