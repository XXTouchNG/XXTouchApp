//
//  XXKeyPressConfigOperationTableViewController.h
//  XXTouchApp
//
//  Created by Zheng on 9/12/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXLocalDataService.h"

typedef enum : NSUInteger {
    kXXKeyPressConfigPressVolumeUpSection = 0,
    kXXKeyPressConfigPressVolumeDownSection,
    kXXKeyPressConfigHoldVolumeUpSection,
    kXXKeyPressConfigHoldVolumeDownSection,
} kXXKeyPressConfigSection;

@interface XXKeyPressConfigOperationTableViewController : UITableViewController
@property (nonatomic, assign) kXXKeyPressConfigSection currentSection;

@end
