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
#import "NSFileManager+RealDestination.h"

@interface XXSwipeableCell()
@property (weak, nonatomic) IBOutlet UIImageView *fileTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileModifiedTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;

@end

@implementation XXSwipeableCell

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    _checkmarkImageView.hidden = !checked;
    if (checked) {
        _fileNameLabel.textColor = STYLE_TINT_COLOR;
    } else {
        _fileNameLabel.textColor = [UIColor blackColor];
    }
}

- (void)setSelectBootscript:(BOOL)selectBootscript {
    _selectBootscript = selectBootscript;
    if (selectBootscript) {
        [_checkmarkImageView setImage:[UIImage imageNamed:@"checkmark-boot"]];
    } else {
        [_checkmarkImageView setImage:[UIImage imageNamed:@"checkmark"]];
    }
}

- (void)setDisplayName:(NSString *)displayName {
    _displayName = displayName;
    _fileNameLabel.text = displayName;
}

- (void)setItemAttrs:(NSDictionary *)itemAttrs {
    self.checked = NO;
    _itemAttrs = itemAttrs;
    id fileType = [itemAttrs objectForKey:NSFileType];
    NSString *fileExt = [_itemPath pathExtension];
    if (fileType == NSFileTypeDirectory) {
        _fileTypeImageView.image = [UIImage imageNamed:@"file-folder"];
        _isDirectory = YES;
        _selectable = NO;
        _editable = NO;
        _fileNameLabel.textColor = [UIColor blackColor];
    } else if (fileType == NSFileTypeSymbolicLink) { // Should Follow To Determine
        NSError *err = nil;
        NSString *destPath = [[NSFileManager defaultManager] realDestinationOfSymbolicLinkAtPath:self.itemPath error:&err];
        if (err == nil) {
            NSDictionary *destAttrs = [FCFileManager attributesOfItemAtPath:destPath error:&err];
            if (err == nil) {
                id destFileType = [destAttrs objectForKey:NSFileType];
                if (destFileType == NSFileTypeDirectory) {
                    _fileTypeImageView.image = [UIImage imageNamed:@"file-folder"];
                    _isDirectory = YES;
                } else {
                    _fileTypeImageView.image = [XXQuickLookService fetchDisplayImageForFileExtension:fileExt];
                    _isDirectory = NO;
                }
            }
        }
        _selectable = [XXQuickLookService isSelectableFileExtension:fileExt];
        _editable = [XXQuickLookService isEditableFileExtension:fileExt];
        _fileNameLabel.textColor = STYLE_TINT_COLOR;
    } else {
        _fileTypeImageView.image = [XXQuickLookService fetchDisplayImageForFileExtension:fileExt];
        _isDirectory = NO;
        _selectable = [XXQuickLookService isSelectableFileExtension:fileExt];
        _editable = [XXQuickLookService isEditableFileExtension:fileExt];
        _fileNameLabel.textColor = [UIColor blackColor];
    }
    NSDate *modificationDate = [itemAttrs objectForKey:NSFileModificationDate];
    NSString *formattedDate = [[[XXLocalDataService sharedInstance] defaultDateFormatter] stringFromDate:modificationDate];
    _fileModifiedTimeLabel.text = formattedDate;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [self applyEditingModeBackgroundViewPositionCorrections];
    }
}


/**
 When using a backgroundView or selectedBackgroundView on a custom UITableViewCell
 subclass, iOS 7 currently
 has a bug where tapping the Delete access control reveals the Delete button, only to have
 the background cover it up again! Radar 14940393 has been filed for this. Until solved,
 use this method in your Table Cell's layoutSubviews
 to correct the behavior.
 
 This solution courtesy of cyphers72 on the Apple Developer Forum, who posted the
 working solution here: https://devforums.apple.com/message/873484#873484
 */
- (void)applyEditingModeBackgroundViewPositionCorrections {
    if (!self.editing) { return; } // BAIL. This fix is not needed.
    
    // Assertion: we are in editing mode.
    
    // Do we have a regular background view?
    if (self.backgroundView) {
        // YES: So adjust the frame for that:
        CGRect backgroundViewFrame = self.backgroundView.frame;
        backgroundViewFrame.origin.x = 0;
        self.backgroundView.frame = backgroundViewFrame;
    }
    
    // Do we have a selected background view?
    if (self.selectedBackgroundView) {
        // YES: So adjust the frame for that:
        CGRect selectedBackgroundViewFrame = self.selectedBackgroundView.frame;
        selectedBackgroundViewFrame.origin.x = 0;
        self.selectedBackgroundView.frame = selectedBackgroundViewFrame;
    }
}

@end
