//
//  XXPaymentViewController.m
//  XXTouchApp
//
//  Created by Zheng on 13/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXPaymentViewController.h"
#import "IAPShare.h"
#import <Masonry/Masonry.h>
#import "XXFeatureTableViewCell.h"
#import "XXLocalDataService.h"

static NSString * const kXXIAPProductIDEnv = @"com.xxtouch.XXTouchApp.iap.env";
static NSString * const kXXIAPProductSharedSecret = @"d37371c2b8d948d7897548e163be11e8";
static NSString * const kXXPaymentFeaturesTableViewCellIdentifier = @"kXXPaymentFeaturesTableViewCellIdentifier";
static SKProduct * currentProduct = nil;

@interface XXPaymentViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIBarButtonItem *closeItem;
@property (nonatomic, strong) UIView *welcomeView;
@property (nonatomic, strong) UILabel *thankyouLabel;
@property (nonatomic, strong) UIView *btnGroupView;
@property (nonatomic, strong) UIButton *purchaseBtn;
@property (nonatomic, strong) UIButton *restoreBtn;
@property (nonatomic, strong) UITableView *featuresTableView;
@property (nonatomic, strong) NSArray <NSDictionary <NSString *, id> *> *featuresArray;

@end

@implementation XXPaymentViewController

- (instancetype)init {
    if (self = [super init]) {
        if (![IAPShare sharedHelper].iap)
        {
            NSSet* dataSet = [[NSSet alloc] initWithObjects:kXXIAPProductIDEnv, nil];
            [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
            [IAPShare sharedHelper].iap.production = YES;
        }
        self.featuresArray =
        @[
          @{
              @"titleImage": [UIImage imageNamed:@"feature-console"],
              @"title": NSLocalizedString(@"Built-in Lua Simulator", nil),
              @"subtitle": NSLocalizedString(@"A console with standard input / output which allows you to test Lua Script inside Lua Simulator.", nil),
              },
          @{
              @"titleImage": [UIImage imageNamed:@"feature-snippets"],
              @"title": NSLocalizedString(@"Code Snippets", nil),
              @"subtitle": NSLocalizedString(@"Practical pickers and templates which make creating simulated touching script more easily.", nil),
              },
          @{
              @"titleImage": [UIImage imageNamed:@"feature-font"],
              @"title": NSLocalizedString(@"More Fonts & Sizes", nil),
              @"subtitle": NSLocalizedString(@"Several monospace fonts and sizes, happy coding!", nil),
              },
          @{
              @"titleImage": [UIImage imageNamed:@"feature-search"],
              @"title": NSLocalizedString(@"Regex Search", nil),
              @"subtitle": NSLocalizedString(@"Search by regex expressions, fast and convenient.", nil),
              },
          @{
              @"titleImage": [UIImage imageNamed:@"feature-tabs"],
              @"title": NSLocalizedString(@"Smart Tabs", nil),
              @"subtitle": NSLocalizedString(@"Customize your tabs: audo indent, soft tabs, and tab width.", nil),
              },
          @{
              @"titleImage": [UIImage imageNamed:@"feature-line"],
              @"title": NSLocalizedString(@"Line Numbers", nil),
              @"subtitle": NSLocalizedString(@"It is necessary if you just created a long script...", nil),
              },
          ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Pro Features", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = self.closeItem;
    
    [self.welcomeView addSubview:self.thankyouLabel];
    [self.btnGroupView addSubview:self.purchaseBtn];
    [self.btnGroupView addSubview:self.restoreBtn];
    [self.welcomeView addSubview:self.btnGroupView];
    [self.view addSubview:self.welcomeView];
    [self.view addSubview:self.featuresTableView];
    [self updateViewConstraints];
    
    [self checkPurchase];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [self.welcomeView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(128));
    }];
    [self.thankyouLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.welcomeView.mas_top).offset(16);
        make.left.equalTo(self.welcomeView.mas_left).offset(48);
        make.right.equalTo(self.welcomeView.mas_right).offset(-48);
        make.height.equalTo(@(48));
    }];
    [self.btnGroupView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.thankyouLabel.mas_bottom).offset(12);
        make.height.equalTo(@(32));
        make.width.equalTo(@(256));
        make.centerX.equalTo(self.thankyouLabel.mas_centerX);
    }];
    [self.purchaseBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.btnGroupView.mas_left);
        make.top.equalTo(self.btnGroupView.mas_top);
        make.height.equalTo(@(28));
        make.width.equalTo(@(96));
    }];
    [self.restoreBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.btnGroupView.mas_right);
        make.top.equalTo(self.btnGroupView.mas_top);
        make.height.equalTo(@(28));
        make.width.equalTo(@(96));
    }];
    [self.featuresTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.welcomeView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

#pragma mark - IAP

- (void)checkPurchase {
    BOOL localPurchased = [[XXLocalDataService sharedInstance] purchasedProduct];
    if (
        [[IAPShare sharedHelper].iap isPurchasedProductsIdentifier:kXXIAPProductIDEnv] ||
        localPurchased
        )
    {
        self.purchaseBtn.enabled = NO;
        self.restoreBtn.enabled = NO;
        self.thankyouLabel.text = NSLocalizedString(@"Thank you for buying XXTouch Pro Features, you're awesome!", nil);
        if (!localPurchased) {
            [[XXLocalDataService sharedInstance] setPurchasedProduct:YES];
            [self alertWithMessage:NSLocalizedString(@"Purchase restored automatically, thank you for your purchase.", nil) exitWhenPressOK:YES];
        }
    }
    else
    {
        self.purchaseBtn.enabled = YES;
        self.restoreBtn.enabled = YES;
        self.thankyouLabel.text = NSLocalizedString(@"XXTouch Pro Features need your purchase to support our development.", nil);
        [self loadProducts];
    }
}

- (void)loadProducts {
    if (currentProduct) {
        NSString *localizedPrice = [[IAPShare sharedHelper].iap getLocalePrice:currentProduct];
        [self enablePurchaseWithPrice:localizedPrice];
    } else {
        @weakify(self);
        [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest* request, SKProductsResponse* response) {
            @strongify(self);
            NSArray <SKProduct *> *products = response.products;
            if (products.count > 0) {
                currentProduct = products[0];
                NSString *localizedPrice = [[IAPShare sharedHelper].iap getLocalePrice:currentProduct];
                [self enablePurchaseWithPrice:localizedPrice];
            }
        }];
    }
}

- (void)enablePurchaseWithPrice:(NSString *)price {
    NSAttributedString *attrPurchaseString = [[NSAttributedString alloc] initWithString:price attributes:
                                              @{
                                                NSFontAttributeName: [UIFont systemFontOfSize:14.f],
                                                NSForegroundColorAttributeName: [UIColor whiteColor],
                                                }];
    [self.purchaseBtn setAttributedTitle:attrPurchaseString forState:UIControlStateNormal];
    self.restoreBtn.userInteractionEnabled = YES;
}

#pragma mark - Getters

- (UILabel *)thankyouLabel {
    if (!_thankyouLabel) {
        UILabel *thankyouLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        thankyouLabel.font = [UIFont systemFontOfSize:14.f];
        thankyouLabel.numberOfLines = 2;
        thankyouLabel.textAlignment = NSTextAlignmentCenter;
        thankyouLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _thankyouLabel = thankyouLabel;
    }
    return _thankyouLabel;
}

- (UIView *)welcomeView {
    if (!_welcomeView) {
        UIView *welcomeView = [[UIView alloc] initWithFrame:CGRectZero];
        welcomeView.backgroundColor = [UIColor colorWithWhite:.97f alpha:1.f];
        _welcomeView = welcomeView;
    }
    return _welcomeView;
}

- (UIView *)btnGroupView {
    if (!_btnGroupView) {
        UIView *btnGroupView = [[UIView alloc] initWithFrame:CGRectZero];
        _btnGroupView = btnGroupView;
    }
    return _btnGroupView;
}

- (UIButton *)purchaseBtn {
    if (!_purchaseBtn) {
        UIButton *purchaseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 96.f, 28.f)];
        purchaseBtn.backgroundColor = [UIColor colorWithRGB:0x1ABC9C];
        purchaseBtn.layer.cornerRadius = 6.f;
        purchaseBtn.showsTouchWhenHighlighted = YES;
        NSAttributedString *attrPurchaseString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Purchase", nil) attributes:
  @{
    NSFontAttributeName: [UIFont systemFontOfSize:14.f],
    NSForegroundColorAttributeName: [UIColor whiteColor],
    }];
        [purchaseBtn setAttributedTitle:attrPurchaseString forState:UIControlStateNormal];
        NSAttributedString *attrPurchasedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Purchased", nil) attributes:
                                                  @{
                                                    NSFontAttributeName: [UIFont systemFontOfSize:14.f],
                                                    NSForegroundColorAttributeName: [UIColor whiteColor],
                                                    }];
        [purchaseBtn setAttributedTitle:attrPurchasedString forState:UIControlStateDisabled];
        [purchaseBtn setTarget:self action:@selector(purchaseBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        _purchaseBtn = purchaseBtn;
    }
    return _purchaseBtn;
}

- (UIButton *)restoreBtn {
    if (!_restoreBtn) {
        UIButton *restoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 96.f, 28.f)];
        restoreBtn.userInteractionEnabled = NO;
        restoreBtn.backgroundColor = [UIColor colorWithRGB:0xBDC3C7];
        restoreBtn.layer.cornerRadius = 6.f;
        restoreBtn.showsTouchWhenHighlighted = YES;
        NSAttributedString *attrRestoreString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Restore", nil) attributes:
                                                  @{
                                                    NSFontAttributeName: [UIFont systemFontOfSize:14.f],
                                                    NSForegroundColorAttributeName: [UIColor whiteColor],
                                                    }];
        [restoreBtn setAttributedTitle:attrRestoreString forState:UIControlStateNormal];
        [restoreBtn setTarget:self action:@selector(restoreBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        _restoreBtn = restoreBtn;
    }
    return _restoreBtn;
}

- (UIBarButtonItem *)closeItem {
    if (!_closeItem) {
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(closeItemTapped:)];
        closeItem.tintColor = [UIColor whiteColor];
        _closeItem = closeItem;
    }
    return _closeItem;
}

- (UITableView *)featuresTableView {
    if (!_featuresTableView) {
        UITableView *featuresTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        featuresTableView.delegate = self;
        featuresTableView.dataSource = self;
        featuresTableView.allowsSelection = NO;
        _featuresTableView = featuresTableView;
    }
    return _featuresTableView;
}

#pragma mark - Actions

- (void)closeItemTapped:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^() {
        if (self.activity && !self.activity.activeDirectly) {
            [self.activity activityDidFinish:YES];
        }
    }];
}

- (void)purchaseBtnTapped:(UIButton *)sender {
    if (!currentProduct) {
        [self.navigationController.view makeToast:NSLocalizedString(@"Product is not ready, please try again in a little while.", nil)];
        return;
    }
    @weakify(self);
    self.navigationController.view.userInteractionEnabled = NO;
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    [[IAPShare sharedHelper].iap buyProduct:currentProduct
                               onCompletion:^(SKPaymentTransaction* trans) {
                                   @strongify(self);
                                   if (trans.error) {
                                       [self alertWithMessage:[trans.error localizedDescription] exitWhenPressOK:NO];
                                       [self.navigationController.view hideToastActivity];
                                       self.navigationController.view.userInteractionEnabled = YES;
                                   }
                                   else if (trans.transactionState == SKPaymentTransactionStatePurchased) {
                                       [[IAPShare sharedHelper].iap checkReceipt:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] AndSharedSecret:kXXIAPProductSharedSecret onCompletion:^(NSString *response, NSError *error) {
                                           NSDictionary* rec = [IAPShare toJSON:response];
                                           if ([rec[@"status"] integerValue] == 0) {
                                               [[IAPShare sharedHelper].iap provideContentWithTransaction:trans];
                                               [[XXLocalDataService sharedInstance] setPurchasedProduct:YES];
                                               [self alertWithMessage:NSLocalizedString(@"Thanks for your purchase!", nil) exitWhenPressOK:YES];
                                           } else {
                                               [self alertWithMessage:NSLocalizedString(@"We cannot verify your receipt, please try again in a little while.", nil) exitWhenPressOK:NO];
                                           }
                                           [self.navigationController.view hideToastActivity];
                                           self.navigationController.view.userInteractionEnabled = YES;
                                       }];
                                   }
                                   else if (trans.transactionState == SKPaymentTransactionStateFailed)
                                   {
                                       [self alertWithMessage:NSLocalizedString(@"We cannot handle with your transaction, please try again in a little while.", nil) exitWhenPressOK:NO];
                                       [self.navigationController.view hideToastActivity];
                                       self.navigationController.view.userInteractionEnabled = YES;
                                   }
                               }];
}

- (void)restoreBtnTapped:(UIButton *)sender {
    if (!currentProduct) return;
    @weakify(self);
    self.navigationController.view.userInteractionEnabled = NO;
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    [[IAPShare sharedHelper].iap restoreProductsWithCompletion:^(SKPaymentQueue *payment, NSError *error) {
        @strongify(self);
        for (SKPaymentTransaction *transaction in payment.transactions) {
            NSString *purchased = transaction.payment.productIdentifier;
            if ([purchased isEqualToString:kXXIAPProductIDEnv]) {
                [[XXLocalDataService sharedInstance] setPurchasedProduct:YES];
                [self alertWithMessage:NSLocalizedString(@"Purchase restored, thank you for your purchase.", nil) exitWhenPressOK:YES];
                break;
            }
        }
        [self.navigationController.view hideToastActivity];
        self.navigationController.view.userInteractionEnabled = YES;
    }];
}

#pragma mark - Alert

- (void)alertWithMessage:(NSString *)message exitWhenPressOK:(BOOL)exit {
    NSString *title = nil;
    if (exit) {
        title = NSLocalizedString(@"Transaction Succeed", nil);
    } else {
        title = NSLocalizedString(@"Transaction Failed", nil);
    }
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
    @weakify(self);
    [alertView addButtonWithTitle:NSLocalizedString(@"OK", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
        @strongify(self);
        if (exit) {
            [self closeItemTapped:nil];
        }
    }];
    [alertView show];
}

#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 128.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.featuresArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XXFeatureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kXXPaymentFeaturesTableViewCellIdentifier];
    if (nil == cell)
    {
        cell = [[XXFeatureTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kXXPaymentFeaturesTableViewCellIdentifier];
    }
    cell.titleImage = self.featuresArray[indexPath.row][@"titleImage"];
    cell.title = self.featuresArray[indexPath.row][@"title"];
    cell.subtitle = self.featuresArray[indexPath.row][@"subtitle"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

#pragma mark - Memory

- (void)dealloc {
    XXLog(@"");
}

@end
