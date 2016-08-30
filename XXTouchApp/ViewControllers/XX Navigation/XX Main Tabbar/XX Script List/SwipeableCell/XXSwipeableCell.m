//
//  XXSwipeableCell.m
//  XXTouchApp
//
//  Created by Zheng on 8/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXSwipeableCell.h"

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

@end
