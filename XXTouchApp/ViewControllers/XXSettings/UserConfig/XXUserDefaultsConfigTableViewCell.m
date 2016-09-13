//
//  XXUserDefaultsConfigTableViewCell.m
//  XXTouchApp
//
//  Created by Zheng on 9/13/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXUserDefaultsConfigTableViewCell.h"

@interface XXUserDefaultsConfigTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *configTitle;
@property (weak, nonatomic) IBOutlet UILabel *configDescription;
@property (weak, nonatomic) IBOutlet UILabel *configValue;

@property (nonatomic, strong) NSArray <NSString *>* configArray;
@property (nonatomic, assign) NSInteger configIndex;

@end

@implementation XXUserDefaultsConfigTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setConfigInfo:(NSMutableDictionary *)configInfo {
    _configInfo = configInfo;
    if (configInfo) {
        _configTitle.text = (NSString *)configInfo[kXXUserDefaultsConfigTitle];
        _configDescription.text = (NSString *)configInfo[kXXUserDefaultsConfigDescription];
        _configArray = (NSArray *)configInfo[kXXUserDefaultsConfigChoices];
        _configIndex = [(NSNumber *)configInfo[kXXUserDefaultsConfigValue] integerValue];
        if (_configArray.count > _configIndex) {
            _configValue.text = _configArray[_configIndex];
        }
    }
}

@end
