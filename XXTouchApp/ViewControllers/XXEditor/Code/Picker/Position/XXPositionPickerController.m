//
//  XXPositionPickerController.m
//  XXTouchApp
//
//  Created by Zheng on 18/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXPositionPickerController.h"

@interface XXPositionPickerController ()

@end

@implementation XXPositionPickerController

@synthesize localizedStrings = _localizedStrings;

- (kPECropViewType)cropViewType {
    return kPECropViewTypePosition;
}

- (NSDictionary <NSString *, NSString *> *)localizedStrings {
    if (!_localizedStrings) {
        _localizedStrings = @{ kXXLocalizedStringKeyTitle: NSLocalizedString(@"Position", nil),
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
    return [self stringFromPoint:self.currentPoint tips:NO];
}

#pragma mark - Points

- (NSString *)stringFromPoint:(CGPoint)p tips:(BOOL)tips {
    NSString *pFormat = nil;
    if (tips) {
        pFormat = @"x = %d, y = %d";
    } else {
        pFormat = @"%d, %d";
    }
    return [NSString stringWithFormat:pFormat, p.x, p.y];
}

- (void)setCurrentPoint:(CGPoint)currentPoint {
    _currentPoint = currentPoint;
    self.subtitle = [self stringFromPoint:currentPoint tips:YES];
}

#pragma mark - Memory

- (void)dealloc {
    CYLog(@"");
}

@end
