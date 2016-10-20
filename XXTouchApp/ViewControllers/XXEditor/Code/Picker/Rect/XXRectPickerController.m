//
//  XXRectPickerController.m
//  XXTouchApp
//
//  Created by Zheng on 10/10/16.
//  Copyright (c) 2016 Zheng. All rights reserved.
//

#import "XXRectPickerController.h"

@interface XXRectPickerController ()

@end

@implementation XXRectPickerController

@synthesize localizedStrings = _localizedStrings;

- (kXXCropViewType)cropViewType {
    return kXXCropViewTypeRect;
}

- (NSDictionary <NSString *, NSString *> *)localizedStrings {
    if (!_localizedStrings) {
        _localizedStrings = @{ kXXLocalizedStringKeyTitle: NSLocalizedString(@"Rectangle", nil),
                               kXXLocalizedStringKeyErrorLoadFile: NSLocalizedString(@"Cannot load image from temporarily file", nil),
                               kXXLocalizedStringKeySelectImage: NSLocalizedString(@"Select an image from album", nil),
                               kXXLocalizedStringKeySelected: NSLocalizedString(@"Select a rectangular area", nil),
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
    return [self stringFromRect:self.cropView.zoomedCropRect tips:NO];
}

#pragma mark - Rects

- (NSString *)stringFromRect:(CGRect)cropRect tips:(BOOL)tips {
    NSString *rectFormat = nil;
    if (tips) {
        rectFormat = @"x1 = %d, y1 = %d, x2 = %d, y2 = %d";
    } else {
        rectFormat = @"%d, %d, %d, %d";
    }
    return [NSString stringWithFormat:rectFormat,
            (int)cropRect.origin.x,
            (int)cropRect.origin.y,
            (int)cropRect.origin.x + (int)cropRect.size.width,
            (int)cropRect.origin.y + (int)cropRect.size.height];
}

- (void)setCurrentRect:(CGRect)currentRect {
    _currentRect = currentRect;
    self.subtitle = [self stringFromRect:currentRect tips:YES];
}

#pragma mark - Memory

- (void)dealloc {
    CYLog(@"");
}

@end
