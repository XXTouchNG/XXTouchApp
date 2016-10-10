//
//  XXImagePickerPhotoCell.m
//  XXImagePickerController
//
//  Created by Donobono on 2014. 1. 23..
//

#import "XXImagePickerPhotoCell.h"

@implementation XXImagePickerPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelectMode:(BOOL)bSelect
{
    if (bSelect)
        _ivPhoto.alpha = 0.2;
    else
        _ivPhoto.alpha = 1.0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
