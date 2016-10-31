//
//  XXSwipeableCell.m
//  XXTouchApp
//
//  Created by Zheng on 8/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXSwipeableCell.h"
#import "XXLocalDataService.h"
#import "XXQuickLookService.h"

@interface XXSwipeableCell()
@property (weak, nonatomic) IBOutlet UIImageView *fileTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileModifiedTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;

@end

@implementation XXSwipeableCell

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    self.checkmarkImageView.hidden = !checked;
    if (checked) {
        self.fileNameLabel.textColor = [UIColor colorWithRGB:0x1abc9c];
    } else if (self.itemAttrs[kXXItemSymbolAttrsKey] || self.itemAttrs[kXXItemSpecialKey]) {
        self.fileNameLabel.textColor = STYLE_TINT_COLOR;
    } else if (self.isSymbolicLink) {
        self.fileNameLabel.textColor = [UIColor colorWithRGB:0xe74c3c];
    } else {
        self.fileNameLabel.textColor = [UIColor blackColor];
    }
}

- (void)setSelectBootscript:(BOOL)selectBootscript {
    _selectBootscript = selectBootscript;
    if (selectBootscript) {
        [self.checkmarkImageView setImage:[UIImage imageNamed:@"checkmark-boot"]];
    } else {
        [self.checkmarkImageView setImage:[UIImage imageNamed:@"checkmark"]];
    }
}

- (BOOL)isDirectory {
    NSString *fileType = self.itemAttrs[NSFileType];
    return ([fileType isEqualToString:NSFileTypeDirectory] ||
            (
             [fileType isEqualToString:NSFileTypeSymbolicLink] &&
             self.itemAttrs[kXXItemSymbolAttrsKey] &&
             [self.itemAttrs[kXXItemSymbolAttrsKey][NSFileType] isEqualToString:NSFileTypeDirectory]
            )
            );
}

- (BOOL)isSymbolicLink {
    return [self.itemAttrs[NSFileType] isEqualToString:NSFileTypeSymbolicLink];
}

- (BOOL)isSelectable {
    if (!self.canOperate) return NO;
    return [XXQuickLookService isSelectableFileExtension:[self.itemAttrs[kXXItemPathKey] pathExtension]];
}

- (BOOL)isEditable {
    if (!self.canOperate) return NO;
    return YES;
}

- (BOOL)canOperate {
    return self.itemAttrs[kXXItemSpecialKey] == nil;
}

- (void)setItemAttrs:(NSDictionary *)itemAttrs {
    _itemAttrs = itemAttrs;
    self.checked = NO;
    self.fileNameLabel.text = itemAttrs[kXXItemNameKey];
    if (itemAttrs[kXXItemSpecialKey]) {
        self.fileTypeImageView.image = [XXQuickLookService fetchDisplayImageForSpecialItem:itemAttrs[kXXItemSpecialKey]];
    } else {
        NSString *fileExt = [itemAttrs[kXXItemPathKey] pathExtension];
        self.fileTypeImageView.image = self.isDirectory ? [UIImage imageNamed:@"file-folder"] : [XXQuickLookService fetchDisplayImageForFileExtension:fileExt];
    }
    NSDate *modificationDate = itemAttrs[NSFileModificationDate];
    NSString *formattedDate = [[[XXLocalDataService sharedInstance] shortDateFormatter] stringFromDate:modificationDate];
    self.fileModifiedTimeLabel.text = formattedDate;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
