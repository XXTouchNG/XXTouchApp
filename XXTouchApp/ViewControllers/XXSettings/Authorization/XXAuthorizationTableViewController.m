//
//  XXAuthorizationTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/10/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

//#include <sys/time.h>
//#include <unistd.h>
#import "XXAuthorizationTableViewController.h"
#import "XXLocalDataService.h"
#import "XXLocalNetService.h"

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

@end

@implementation XXAuthorizationTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(reloadDeviceAndAuthorizationInfo:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
    self.submitButton.tintColor = [UIColor whiteColor];
    
    self.clearsSelectionOnViewWillAppear = YES; // Override
    self.authorizationField.text = self.code;
    self.authorizationField.delegate = self;
    
    if (![self loadDeviceAndAuthorizationInfo]) {
        [self reloadDeviceAndAuthorizationInfo:nil];
    }
    
    {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        tapGesture.cancelsTouchesInView = NO;
        [self.view addGestureRecognizer:tapGesture];
    }
    
    self.submitButton.enabled = (self.authorizationField.text.length != 0);
}

- (void)endBindingCodeAndGetDeviceInfo {
    self.authorizationField.text = @"";
    NSMutableString *intervalString = [[NSMutableString alloc] init];
    NSTimeInterval interval = [[XXTGSSI.dataService expirationDate] timeIntervalSinceDate:[XXTGSSI.dataService nowDate]];
    int intervalDay = (int)floor(interval / 86400);
    if (intervalDay != 0)
    {
        [intervalString appendFormat:NSLocalizedString(@"%d Day(s) ", nil), intervalDay];
    }
    int intervalHour = (int)floor((interval - intervalDay * 86400) / 3600);
    [intervalString appendFormat:NSLocalizedString(@"%d Hour(s) ", nil), intervalHour];
    NSString *eMsg = [NSString stringWithFormat:NSLocalizedString(@"Operation succeed, added %@", nil), intervalString];
    @weakify(self);
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Code binding succeed", nil) andMessage:eMsg];
    [alertView addButtonWithTitle:NSLocalizedString(@"OK", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView1) {
                              @strongify(self);
                              // Begin
                              [self reloadDeviceAndAuthorizationInfo:nil];
                              if (self.fromScan) {
                                  [self.navigationItem.leftBarButtonItem setTitle:NSLocalizedString(@"Close", nil)];
                              }
                          }];
    [alertView show];
}

- (IBAction)submit:(id)sender {
    if ([self.authorizationField isFirstResponder])
    {
        [self.authorizationField resignFirstResponder];
    }
    __block NSString *codeText = self.authorizationField.text;
    if (![codeText matchesRegex:@"^[3-9a-zA-Z]*$" options:0]) {
        [self.navigationController.view makeToast:NSLocalizedString(@"The code only contains 3-9, a-z and A-Z.", nil)];
        return;
    }
    if (codeText.length < 10 || codeText.length > 20) {
        [self.navigationController.view makeToast:NSLocalizedString(@"Your password must be 10-20 characters long.", nil)];
        return;
    }
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
    if ([self.authorizationField isFirstResponder]) {
        [self.authorizationField resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.authorizationField) {
        if ([string containsString:@"0"] || [string containsString:@"1"] || [string containsString:@"2"]) {
            return NO;
        }
    }
    return YES;
}

- (void)reloadDeviceAndAuthorizationInfo:(UIRefreshControl *)sender {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        __block NSError *err = nil;
        BOOL result = [XXLocalNetService localGetDeviceInfoWithError:&err];
        if (result) {
            result = [XXLocalNetService remoteGetDeviceAuthInfoWithError:&err];
        }
        dispatch_async_on_main_queue(^{
            if ([sender isRefreshing]) {
                [sender endRefreshing];
            }
            if (!result) {
                [self.navigationController.view makeToast:[err localizedDescription]];
            } else {
                [self loadDeviceAndAuthorizationInfo];
//                NSDate *nowDate = [XXTGSSI.dataService nowDate];
//                if (fabs([nowDate timeIntervalSinceDate:[NSDate date]]) > 120.f)
//                {
//                    struct tm *t_tm;
//                    struct timeval t_timeval;
//                    time_t t_timet;
//                    t_timet = time(NULL);
//                    t_tm = localtime(&t_timet);
//                    t_tm->tm_hour = (int)nowDate.hour;
//                    t_tm->tm_min = (int)nowDate.minute;
//                    t_tm->tm_sec = (int)nowDate.second;
//                    t_tm->tm_year = (int)nowDate.year;
//                    t_tm->tm_mon = (int)nowDate.month - 1;
//                    t_tm->tm_mday = (int)nowDate.day;
//                    t_timet = mktime(t_tm);
//                    t_timeval.tv_sec = t_timet;
//                    t_timeval.tv_usec = 0;
//                    int rec = settimeofday(&t_timeval, NULL);
//                    if (rec == -1) {
//                        [self.navigationController.view makeToast:NSLocalizedString(@"Cannot calibrate local time: Permission Denied", nil)];
//                    } else if (rec == 0) {
//                        [self.navigationController.view makeToast:NSLocalizedString(@"Local time has been calibrated", nil)];
//                    }
//                }
            }
        });
    });
}

- (BOOL)loadDeviceAndAuthorizationInfo {
    NSDictionary *deviceInfo = [XXTGSSI.dataService deviceInfo];
    NSDate *expirationDate = [XXTGSSI.dataService expirationDate];
    NSDate *nowDate = [XXTGSSI.dataService nowDate];
    if (deviceInfo != nil &&
        expirationDate != nil &&
        nowDate != nil) {
        self.authorizationField.enabled = YES;
        self.expiredAtLabel.textColor = ([nowDate timeIntervalSinceDate:expirationDate] >= 0) ? [UIColor redColor] : STYLE_TINT_COLOR;
        self.expiredAtLabel.text = [[XXTGSSI.dataService defaultDateFormatter] stringFromDate:expirationDate];
        self.softwareVersionLabel.text = deviceInfo[kXXDeviceInfoSoftwareVersion];
        self.systemVersionLabel.text = deviceInfo[kXXDeviceInfoSystemVersion];
        self.deviceTypeLabel.text = deviceInfo[kXXDeviceInfoDeviceType];
        self.deviceNameLabel.text = deviceInfo[kXXDeviceInfoDeviceName];
        self.serialLabel.text = deviceInfo[kXXDeviceInfoSerialNumber];
        self.macAddressLabel.text = deviceInfo[kXXDeviceInfoMacAddress];
        self.uniqueIDLabel.text = deviceInfo[kXXDeviceInfoUniqueID];
        return YES;
    } else {
        self.authorizationField.enabled = NO;
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
        [self.navigationController.view makeToast:NSLocalizedString(@"Copied to the clipboard", nil)];
    }
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if ([self.authorizationField isFirstResponder]) {
        [self.authorizationField resignFirstResponder];
    }
    [super dismissViewControllerAnimated:flag completion:completion];
}

- (void)dealloc {
    XXLog(@"");
}

@end
