//
//  XXTBasePicker.h
//  XXTLocationPicker
//
//  Created by Zheng on 15/04/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#ifndef XXTBasePicker_h
#define XXTBasePicker_h

#import "XXTPickerTask.h"

@protocol XXTBasePicker <NSObject>
@property (nonatomic, strong) XXTPickerTask *pickerTask;

+ (NSString *)pickerKeyword;
- (NSString *)pickerResult;

@optional
- (NSString *)pickerSubtitle;
- (NSAttributedString *)pickerAttributedSubtitle;

@end

#endif /* XXTBasePicker_h */
