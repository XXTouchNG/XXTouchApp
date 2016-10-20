//
//  XXImageFlagView.h
//  XXTouchApp
//
//  Created by Zheng on 20/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXPositionColorModel.h"

@interface XXImageFlagView : UIView
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) CGPoint originalPoint;
@property (nonatomic, strong) XXPositionColorModel *dataModel;

@end
