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

- (void)setConfigInfo:(XXUserDefaultsModel *)configInfo {
    _configInfo = configInfo;
    if (configInfo) {
        _configTitle.text = _configInfo.configTitle;
        _configDescription.text = _configInfo.configDescription;
        if (_configInfo.configChoices.count > _configInfo.configValue) {
            _configValue.text = _configInfo.configChoices[_configInfo.configValue];
        }
    }
}

@end
