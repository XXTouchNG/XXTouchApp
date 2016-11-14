//
//  XXMediaViewController.h
//  XXTouchApp
//
//  Created by Zheng on 14/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "XXBaseActivity.h"

@interface XXMediaViewController : MPMoviePlayerViewController
@property (nonatomic, weak) XXBaseActivity *activity;

@end
