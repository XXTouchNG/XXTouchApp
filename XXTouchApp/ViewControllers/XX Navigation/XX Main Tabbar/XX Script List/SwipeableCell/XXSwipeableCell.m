//
//  XXSwipeableCell.m
//  XXTouchApp
//
//  Created by Zheng on 8/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXSwipeableCell.h"
#import "XXLocalDataService.h"

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
}

- (void)setDisplayName:(NSString *)displayName {
    _displayName = displayName;
//    if (self.isUpperDirectory) {
//        self.fileNameLabel.text = NSLocalizedStringFromTable(@"..", @"XXTouch", nil);
//        self.fileNameLabel.textColor = STYLE_TINT_COLOR;
//    } else {
        self.fileNameLabel.text = displayName;
        self.fileNameLabel.textColor = [UIColor blackColor];
//    }
}

- (void)setItemAttrs:(NSDictionary *)itemAttrs {
    id fileType = [itemAttrs objectForKey:NSFileType];
    if (fileType == NSFileTypeDirectory || fileType == NSFileTypeSymbolicLink) {
        // directory
        self.fileTypeImageView.image = [UIImage imageNamed:@"file-folder"];
        _isDirectory = YES;
        _selectable = NO;
        _editable = NO;
    } else {
        self.fileTypeImageView.image = [UIImage imageNamed:@"file-unknown"];
        _isDirectory = NO;
        _selectable = NO;
        _editable = NO;
    }
    NSDate *modificationDate = [itemAttrs objectForKey:NSFileModificationDate];
    NSString *formattedDate = [[[XXLocalDataService sharedInstance] defaultDateFormatter] stringFromDate:modificationDate];
    self.fileModifiedTimeLabel.text = formattedDate;
}

@end
