//
//  XXColorPickerController.m
//  XXTouchApp
//
//  Created by Zheng on 19/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXColorPickerController.h"

@interface XXColorPickerController ()

@end

@implementation XXColorPickerController

@synthesize localizedStrings = _localizedStrings;

+ (NSString *)keyword {
    return @"@color@";
}

- (kXXCropViewType)cropViewType {
    return kXXCropViewTypeColor;
}

- (NSDictionary <NSString *, NSString *> *)localizedStrings {
    if (!_localizedStrings) {
        _localizedStrings = @{ kXXLocalizedStringKeyTitle: NSLocalizedString(@"Color", nil),
                               kXXLocalizedStringKeyErrorLoadFile: NSLocalizedString(@"Cannot load image from temporarily file", nil),
                               kXXLocalizedStringKeySelectImage: NSLocalizedString(@"Select an image from album", nil),
                               kXXLocalizedStringKeySelected: NSLocalizedString(@"Select a color by tapping on image", nil),
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
    return [self stringFromColor:self.currentColor tips:NO];
}

#pragma mark - Points

- (NSString *)stringFromColor:(UIColor *)color tips:(BOOL)tips {
    UIColor *c = [color copy];
    if (!c) {
        c = [UIColor blackColor];
    }
    if (tips) {
        return [NSString stringWithFormat:@"R: %d, G: %d, B: %d, A: %.2f (#%@)", (int)(c.red * 255.f), (int)(c.green * 255.f), (int)(c.blue * 255.f), c.alpha, [c hexString]];
    } else {
        return [NSString stringWithFormat:@"0x%@", [c hexString]];
    }
    return @"";
}

- (void)setCurrentColor:(UIColor *)currentColor {
    _currentColor = currentColor;
    self.subtitle = [self stringFromColor:currentColor tips:YES];
}

#pragma mark - Memory

- (void)dealloc {
    XXLog(@"");
}

@end
