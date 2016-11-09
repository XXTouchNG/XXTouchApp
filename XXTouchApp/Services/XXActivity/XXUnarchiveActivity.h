//
//  XXUnarchiveActivity.h
//  XXTouchApp
//
//  Created by Zheng on 09/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXBaseActivity.h"

@protocol XXUnarchiveDelegate <NSObject>
- (void)archiveDidUnArchiveAtPath:(NSString *)path
                     unzippedPath:(NSString *)unzippedPath;

@end

@interface XXUnarchiveActivity : XXBaseActivity
@property (nonatomic, weak) id<XXUnarchiveDelegate> delegate;

@end
