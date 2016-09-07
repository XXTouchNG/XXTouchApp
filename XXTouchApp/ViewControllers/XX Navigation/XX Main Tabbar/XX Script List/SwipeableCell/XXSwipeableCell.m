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
    _checkmarkImageView.hidden = !checked;
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

@end
