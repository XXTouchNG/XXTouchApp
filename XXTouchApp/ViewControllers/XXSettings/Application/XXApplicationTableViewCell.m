//
//  XXApplicationTableViewCell.m
//  XXTouchApp
//
//  Created by Zheng on 9/11/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXApplicationTableViewCell.h"

@interface XXApplicationTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *appLabel;
@property (weak, nonatomic) IBOutlet UILabel *bundleIDLabel;

@end

@implementation XXApplicationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAppInfo:(NSDictionary *)appInfo {
    _appInfo = appInfo;
    if (appInfo) {
        self.iconImageView.image = [UIImage imageWithData:[NSData dataWithBase64EncodedString:[appInfo objectForKey:kXXApplicationKeyIcon]]];
        self.appLabel.text = [appInfo objectForKey:kXXApplicationKeyAppName];
        self.bundleIDLabel.text = [appInfo objectForKey:kXXApplicationKeyBundleID];
    }
}

@end
