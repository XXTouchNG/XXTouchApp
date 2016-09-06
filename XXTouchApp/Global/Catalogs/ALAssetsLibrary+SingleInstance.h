//
//  ALAssetsLibrary+SingleInstance.h
//  XXTouchApp
//
//  Created by Zheng on 9/6/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (SingleInstance)
+ (ALAssetsLibrary *)sharedLibrary;

@end
