//
//  XXAuthorizationTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/10/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXAuthorizationTableViewController.h"
#import "XXLocalDataService.h"
#import "XXLocalNetService.h"
#import <MJRefresh/MJRefresh.h>

enum {
    kXXAuthorizationRechargeSection = 0,
    kXXAuthorizationActivationSection,
    kXXAuthorizationDeviceSection,
};

enum {
    kXXAuthorizationCodeIndex = 0,
};

enum {
    kXXAuthorizationExpiredAtIndex = 0,
};

enum {
    kXXAuthorizationSoftwareVersionIndex = 0,
    kXXAuthorizationSystemVersionIndex,
    kXXAuthorizationDeviceTypeIndex,
    kXXAuthorizationDeviceNameIndex,
    kXXAuthorizationSerialNumberIndex,
    kXXAuthorizationMacAddressIndex,
    kXXAuthorizationUniqueIDIndex,
};

@interface XXAuthorizationTableViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;

@property (weak, nonatomic) IBOutlet UITextField *authorizationField;
@property (weak, nonatomic) IBOutlet UILabel *expiredAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *softwareVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *systemVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialLabel;
@property (weak, nonatomic) IBOutlet UILabel *macAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *uniqueIDLabel;

@property (nonatomic, strong) MJRefreshNormalHeader *refreshHeader;


@end

@implementation XXAuthorizationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.mj_header = self.refreshHeader;
    if (![self loadDeviceAndAuthorizationInfo]) {
        [self.refreshHeader beginRefreshing];
    }
    
    {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        tapGesture.cancelsTouchesInView = NO;
        [self.view addGestureRecognizer:tapGesture];
    }
}

- (IBAction)submit:(id)sender {
    if ([_authorizationField isFirstResponder]) {
        [_authorizationField resignFirstResponder];
    }
    __block NSString *codeText = self.authorizationField.text;
    self.navigationController.view.userInteractionEnabled = NO;
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        __block NSError *err = nil;
        BOOL result = [XXLocalNetService localBindCode:codeText error:&err];
        if (result) {
            result = [XXLocalNetService localGetDeviceAuthInfoWithError:&err];
        }
        dispatch_async_on_main_queue(^{
            self.navigationController.view.userInteractionEnabled = YES;
            [self.navigationController.view hideToastActivity];
            if (!result) {
                [self.navigationController.view makeToast:[err localizedDescription]];
            } else {
                _authorizationField.text = @"";
                [self.navigationController.view makeToast:XXLString(@"Code binding succeed.")];
                [self loadDeviceAndAuthorizationInfo];
            }
        });
    });
}

- (IBAction)authorizationFieldChanged:(UITextField *)sender {
    NSString *codeText = sender.text;
    if (codeText.length == 0) {
        self.submitButton.enabled = NO;
    } else {
        self.submitButton.enabled = YES;
    }
}

- (void)viewTapped:(UITapGestureRecognizer *)tapGesture {
    if ([_authorizationField isFirstResponder]) {
        [_authorizationField resignFirstResponder];
    }
}

- (MJRefreshNormalHeader *)refreshHeader {
    if (!_refreshHeader) {
        MJRefreshNormalHeader *normalHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadDeviceAndAuthorizationInfo)];
        [normalHeader setTitle:XXLString(@"Pull down") forState:MJRefreshStateIdle];
        [normalHeader setTitle:XXLString(@"Release") forState:MJRefreshStatePulling];
        [normalHeader setTitle:XXLString(@"Loading...") forState:MJRefreshStateRefreshing];
        normalHeader.stateLabel.font = [UIFont systemFontOfSize:12.0];
        normalHeader.stateLabel.textColor = [UIColor lightGrayColor];
        normalHeader.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightThin];
        normalHeader.lastUpdatedTimeLabel.textColor = [UIColor lightGrayColor];
        _refreshHeader = normalHeader;
    }
    return _refreshHeader;
}

- (void)reloadDeviceAndAuthorizationInfo {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        __block NSError *err = nil;
        BOOL result = [XXLocalNetService localGetDeviceInfoWithError:&err];
        if (result) {
            result = [XXLocalNetService localGetDeviceAuthInfoWithError:&err];
        }
        dispatch_async_on_main_queue(^{
            if ([self.refreshHeader isRefreshing]) {
                [self.refreshHeader endRefreshing];
            }
            if (!result) {
                [self.navigationController.view makeToast:[err localizedDescription]];
            } else {
                [self loadDeviceAndAuthorizationInfo];
            }
        });
    });
}

- (BOOL)loadDeviceAndAuthorizationInfo {
    NSDictionary *deviceInfo = [[XXLocalDataService sharedInstance] deviceInfo];
    NSDate *expirationDate = [[XXLocalDataService sharedInstance] expirationDate];
    if (deviceInfo != nil &&
        expirationDate != nil) {
        self.expiredAtLabel.text = [[[XXLocalDataService sharedInstance] defaultDateFormatter] stringFromDate:expirationDate];
        self.softwareVersionLabel.text = [deviceInfo objectForKey:kXXDeviceInfoSoftwareVersion];
        self.systemVersionLabel.text = [deviceInfo objectForKey:kXXDeviceInfoSystemVersion];
        self.deviceTypeLabel.text = [deviceInfo objectForKey:kXXDeviceInfoDeviceType];
        self.deviceNameLabel.text = [deviceInfo objectForKey:kXXDeviceInfoDeviceName];
        self.serialLabel.text = [deviceInfo objectForKey:kXXDeviceInfoSerialNumber];
        self.macAddressLabel.text = [deviceInfo objectForKey:kXXDeviceInfoMacAddress];
        self.uniqueIDLabel.text = [deviceInfo objectForKey:kXXDeviceInfoUniqueID];
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == kXXAuthorizationDeviceSection) {
        switch (indexPath.row) {
            case kXXAuthorizationSoftwareVersionIndex:
                [[UIPasteboard generalPasteboard] setString:self.softwareVersionLabel.text];
                break;
            case kXXAuthorizationSystemVersionIndex:
                [[UIPasteboard generalPasteboard] setString:self.systemVersionLabel.text];
                break;
            case kXXAuthorizationDeviceTypeIndex:
                [[UIPasteboard generalPasteboard] setString:self.deviceTypeLabel.text];
                break;
            case kXXAuthorizationDeviceNameIndex:
                [[UIPasteboard generalPasteboard] setString:self.deviceNameLabel.text];
                break;
            case kXXAuthorizationSerialNumberIndex:
                [[UIPasteboard generalPasteboard] setString:self.serialLabel.text];
                break;
            case kXXAuthorizationMacAddressIndex:
                [[UIPasteboard generalPasteboard] setString:self.macAddressLabel.text];
                break;
            case kXXAuthorizationUniqueIDIndex:
                [[UIPasteboard generalPasteboard] setString:self.uniqueIDLabel.text];
                break;
            default:
                break;
        }
        [self.navigationController.view makeToast:XXLString(@"Copied to the clipboard.")];
    }
}

- (void)dealloc {
    CYLog(@"");
}

@end
