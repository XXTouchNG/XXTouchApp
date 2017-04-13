//
//  XXBaseTextEditorViewController.h
//  XXTouchApp
//
//  Created by Zheng on 9/18/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

// This text editor is used for simple editing...
// Basically design (the same as what TouchSprite did)

#import <UIKit/UIKit.h>
#import "XXBaseActivity.h"

@interface XXBaseTextEditorViewController : UIViewController
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, weak) XXBaseActivity *activity;


@end
