//
//  XXScanDownloadTaskViewController.h
//  XXTouchApp
//
//  Created by Zheng on 9/15/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XXScanDownloadTaskViewController;

@protocol XXScanDownloadTaskDelegate <NSObject>

@required;
- (void)confirmDownloadTask:(XXScanDownloadTaskViewController *)vc
                     source:(NSString *)sourcePath
                destination:(NSString *)destinationPath;
- (void)cancelDownloadTask:(XXScanDownloadTaskViewController *)vc;

@end

@interface XXScanDownloadTaskViewController : UITableViewController

@property (nonatomic, copy) NSString *sourceUrl;
@property (nonatomic, copy) NSString *destinationUrl;
@property (nonatomic, weak) id<XXScanDownloadTaskDelegate> delegate;

@end
