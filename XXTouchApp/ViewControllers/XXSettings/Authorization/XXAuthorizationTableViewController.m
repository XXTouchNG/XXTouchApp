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

@interface XXAuthorizationTableViewController () <UITextFieldDelegate>
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

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
    self.submitButton.tintColor = [UIColor whiteColor];
    
    self.clearsSelectionOnViewWillAppear = YES; // Override
    self.tableView.mj_header = self.refreshHeader;
    self.authorizationField.text = self.code;
    self.authorizationField.delegate = self;
    
    if (![self loadDeviceAndAuthorizationInfo]) {
        [self.refreshHeader beginRefreshing];
    }
    
    {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        tapGesture.cancelsTouchesInView = NO;
        [self.view addGestureRecognizer:tapGesture];
    }
    
    self.submitButton.enabled = (self.authorizationField.text.length != 0);
}

- (void)endBindingCodeAndGetDeviceInfo {
    _authorizationField.text = @"";
    [self.navigationController.view makeToast:XXLString(@"Code binding succeed.")];
    [self loadDeviceAndAuthorizationInfo];
}

- (IBAction)submit:(id)sender {
    if ([_authorizationField isFirstResponder]) {
        [_authorizationField resignFirstResponder];
    }
    __block NSString *codeText = self.authorizationField.text;
    SendConfigAction([XXLocalNetService remoteBindCode:codeText error:&err], [self endBindingCodeAndGetDeviceInfo]);
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (MJRefreshNormalHeader *)refreshHeader {
    if (!_refreshHeader) {
        MJRefreshNormalHeader *normalHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadDeviceAndAuthorizationInfo)];
        [normalHeader setTitle:XXLString(@"Pull down") forState:MJRefreshStateIdle];
        [normalHeader setTitle:XXLString(@"Release") forState:MJRefreshStatePulling];
        [normalHeader setTitle:XXLString(@"Loading...") forState:MJRefreshStateRefreshing];
        normalHeader.stateLabel.font = [UIFont systemFontOfSize:12.0];
        normalHeader.stateLabel.textColor = [UIColor lightGrayColor];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
            normalHeader.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightThin];
        } else {
            normalHeader.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:12.0];
        }
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
            result = [XXLocalNetService remoteGetDeviceAuthInfoWithError:&err];
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
        _authorizationField.enabled = YES;
        self.expiredAtLabel.text = [[[XXLocalDataService sharedInstance] defaultDateFormatter] stringFromDate:expirationDate];
        self.softwareVersionLabel.text = [deviceInfo objectForKey:kXXDeviceInfoSoftwareVersion];
        self.systemVersionLabel.text = [deviceInfo objectForKey:kXXDeviceInfoSystemVersion];
        self.deviceTypeLabel.text = [deviceInfo objectForKey:kXXDeviceInfoDeviceType];
        self.deviceNameLabel.text = [deviceInfo objectForKey:kXXDeviceInfoDeviceName];
        self.serialLabel.text = [deviceInfo objectForKey:kXXDeviceInfoSerialNumber];
        self.macAddressLabel.text = [deviceInfo objectForKey:kXXDeviceInfoMacAddress];
        self.uniqueIDLabel.text = [deviceInfo objectForKey:kXXDeviceInfoUniqueID];
        return YES;
    } else {
        _authorizationField.enabled = NO;
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

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if ([_authorizationField isFirstResponder]) {
        [_authorizationField resignFirstResponder];
    }
    [super dismissViewControllerAnimated:flag completion:completion];
}

- (void)dealloc {
    CYLog(@"");
}

@end
