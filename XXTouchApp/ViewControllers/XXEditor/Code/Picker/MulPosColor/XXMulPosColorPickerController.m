//
//  XXMulPosColorPickerController.m
//  XXTouchApp
//
//  Created by Zheng on 20/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXMulPosColorPickerController.h"

@interface XXMulPosColorPickerController ()

@end

@implementation XXMulPosColorPickerController

@synthesize localizedStrings = _localizedStrings;

+ (NSString *)keyword {
    return @"@poscolors@";
}

- (kXXCropViewType)cropViewType {
    return kXXCropViewTypeMultiplePositionColor;
}

- (NSDictionary <NSString *, NSString *> *)localizedStrings {
    if (!_localizedStrings) {
        _localizedStrings = @{ kXXLocalizedStringKeyTitle: NSLocalizedString(@"Positions & Colors", nil),
                               kXXLocalizedStringKeyErrorLoadFile: NSLocalizedString(@"Cannot load image from temporarily file", nil),
                               kXXLocalizedStringKeySelectImage: NSLocalizedString(@"Select an image from album", nil),
                               kXXLocalizedStringKeySelected: NSLocalizedString(@"Select several positions by tapping on image", nil),
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
    return [self stringFromPosColors:self.currentArray];
}

#pragma mark - Points

- (NSString *)stringFromPosColors:(NSArray <XXPositionColorModel *> *)poscolors {
    NSMutableString *mulString = [[NSMutableString alloc] initWithString:@"{\n"];
    NSUInteger index = 0;
    for (XXPositionColorModel *poscolor in poscolors) {
        index++;
        UIColor *c = [poscolor.color copy];
        if (!c) c = [UIColor blackColor];
        CGPoint p = poscolor.position;
        [mulString appendFormat:@"\t{ %d, %d, 0x%@ }, -- %lu\n",
         (int)p.x, (int)p.y,
         [c hexString], (unsigned long)index];
    }
    return [mulString stringByAppendingString:@"}"];
}

#pragma mark - Memory

- (void)dealloc {
    CYLog(@"");
}

@end
