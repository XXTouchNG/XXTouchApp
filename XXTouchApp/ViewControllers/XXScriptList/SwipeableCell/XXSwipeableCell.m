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

- (void)setItemAttrs:(NSDictionary *)itemAttrs {
    self.checked = NO;
    _itemAttrs = itemAttrs;
    _fileNameLabel.text = itemAttrs[kXXItemNameKey];
    id fileType = [itemAttrs objectForKey:NSFileType];
    NSString *fileExt = [[itemAttrs[kXXItemNameKey] pathExtension] lowercaseString];
    if (fileType == NSFileTypeDirectory) {
        _fileTypeImageView.image = [UIImage imageNamed:@"file-folder"];
        _fileNameLabel.textColor = [UIColor blackColor];
    } else if (fileType == NSFileTypeSymbolicLink) { // Should Follow To Determine
        NSError *err = nil;
        NSString *destPath = [[NSFileManager defaultManager] realDestinationOfSymbolicLinkAtPath:itemAttrs[kXXItemPathKey] error:&err];
        if (err == nil) {
            NSDictionary *destAttrs = [FCFileManager attributesOfItemAtPath:destPath error:&err];
            if (err == nil) {
                id destFileType = [destAttrs objectForKey:NSFileType];
                if (destFileType == NSFileTypeDirectory) {
                    _fileTypeImageView.image = [UIImage imageNamed:@"file-folder"];
                } else {
                    _fileTypeImageView.image = [XXQuickLookService fetchDisplayImageForFileExtension:fileExt];
                }
            }
        }
        _fileNameLabel.textColor = STYLE_TINT_COLOR;
    } else {
        _fileTypeImageView.image = [XXQuickLookService fetchDisplayImageForFileExtension:fileExt];
        _fileNameLabel.textColor = [UIColor blackColor];
    }
    NSDate *modificationDate = itemAttrs[NSFileModificationDate];
    NSString *formattedDate = [[[XXLocalDataService sharedInstance] shortDateFormatter] stringFromDate:modificationDate];
    _fileModifiedTimeLabel.text = formattedDate;
}

@end
