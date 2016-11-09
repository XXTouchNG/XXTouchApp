//
//  XXArchiveActivity.h
//  XXTouchApp
//
//  Created by Zheng on 09/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXBaseActivity.h"

@protocol XXArchiveDelegate <NSObject>
- (void)archiveDidCreatedAtPath:(NSString *)path;

@end

@interface XXArchiveActivity : XXBaseActivity
@property (nonatomic, weak) id<XXArchiveDelegate> delegate;

@end
