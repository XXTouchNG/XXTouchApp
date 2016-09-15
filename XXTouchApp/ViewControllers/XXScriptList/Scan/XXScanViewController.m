//
//  XXScanViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/15/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "AppDelegate.h"
#import "XXScanViewController.h"
#import "XXWebViewController.h"
#import "XXEmptyNavigationController.h"
#import "XXAuthorizationTableViewController.h"
#import "XXScanDownloadTaskViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

static NSString * const kXXNavigationControllerStoryboardID = @"kXXNavigationControllerStoryboardID";
static NSString * const kXXAuthorizationTableViewControllerStoryboardID = @"kXXAuthorizationTableViewControllerStoryboardID";
static NSString * const kXXDownloadTaskNavigationControllerStoryboardID = @"kXXDownloadTaskNavigationControllerStoryboardID";

@interface XXScanViewController () <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, XXScanDownloadTaskDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layer;

@property (nonatomic, strong) UIImage *maskImage;
@property (nonatomic, strong) UIImageView *maskView;
@property (nonatomic, assign) CGRect cropRect;

@property (nonatomic, strong) UIBarButtonItem *closeItem;
@property (nonatomic, strong) UIBarButtonItem *albumItem;
@property (nonatomic, strong) UIBarButtonItem *closeAuthItem;
@property (nonatomic, strong) UIBarButtonItem *closeWebItem;

@property (nonatomic, weak) XXAuthorizationTableViewController *authController;
@property (nonatomic, weak) XXWebViewController *webController;

@property (nonatomic, assign) BOOL layerLoaded;

@property (nonatomic, weak) UIImagePickerController *picker;

@end

@implementation XXScanViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIModalTransitionStyle)modalTransitionStyle {
    return UIModalTransitionStyleFlipHorizontal;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (AVCaptureSession *)session {
    if (!_session) {
        AVCaptureSession *session = [[AVCaptureSession alloc] init];
        if ([session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            [session setSessionPreset:AVCaptureSessionPresetHigh];
        }
        if ([session canAddInput:self.input]) {
            [session addInput:self.input];
        }
        if ([session canAddOutput:self.output]) {
            [session addOutput:self.output];
        }
        self.output.metadataObjectTypes = @[ AVMetadataObjectTypeQRCode ];
        CGSize viewSize = self.navigationController.view.size;
        self.output.rectOfInterest = CGRectMake(_cropRect.origin.y / viewSize.height,
                                                _cropRect.origin.x / viewSize.width,
                                                _cropRect.size.height / viewSize.height,
                                                _cropRect.size.width / viewSize.width);
        _session = session;
    }
    return _session;
}

- (AVCaptureDevice *)device {
    if (!_device) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _device = device;
    }
    return _device;
}

- (AVCaptureDeviceInput *)input {
    if (!_input) {
        NSError *err = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&err];
        NSAssert(err == nil, @"Cannot create instance of AVCaptureDeviceInput");
        _input = input;
    }
    return _input;
}

- (AVCaptureMetadataOutput *)output {
    if (!_output) {
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        _output = output;
    }
    return _output;
}

- (AVCaptureVideoPreviewLayer *)layer {
    if (!_layer) {
        AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _layer = layer;
    }
    return _layer;
}

- (UIBarButtonItem *)closeItem {
    if (!_closeItem) {
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close:)];
        closeItem.tintColor = [UIColor whiteColor];
        _closeItem = closeItem;
    }
    return _closeItem;
}

- (UIBarButtonItem *)closeAuthItem {
    if (!_closeAuthItem) {
        UIBarButtonItem *closeAuthItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeAuth:)];
        closeAuthItem.tintColor = [UIColor whiteColor];
        _closeAuthItem = closeAuthItem;
    }
    return _closeAuthItem;
}

- (UIBarButtonItem *)closeWebItem {
    if (!_closeWebItem) {
        UIBarButtonItem *closeWebItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeWeb:)];
        closeWebItem.tintColor = [UIColor whiteColor];
        _closeWebItem = closeWebItem;
    }
    return _closeWebItem;
}

- (UIBarButtonItem *)albumItem {
    if (!_albumItem) {
        UIBarButtonItem *albumItem = [[UIBarButtonItem alloc] initWithTitle:XXLString(@"Album") style:UIBarButtonItemStyleBordered target:self action:@selector(album:)];
        albumItem.tintColor = [UIColor whiteColor];
        _albumItem = albumItem;
    }
    return _albumItem;
}

- (void)fetchPermission {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusAuthorized) {
            dispatch_async_on_main_queue(^{
                [self loadLayerFrame];
            });
        } else if (status == AVAuthorizationStatusDenied) {
            dispatch_async_on_main_queue(^{
                self.title = XXLString(@"Access Denied");
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:XXLString(@"Access Denied")
                                                                 andMessage:XXLString(@"Turn to \"Settings > Privacy > Camera\" and enable XXTouch to use your camera.")];
                [alertView addButtonWithTitle:XXLString(@"OK") type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                    
                }];
                [alertView show];
            });
        } else if (status == AVAuthorizationStatusRestricted) {
            dispatch_async_on_main_queue(^{
                self.title = XXLString(@"Access Restricted");
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:XXLString(@"Access Restricted")
                                                                 andMessage:XXLString(@"Turn to \"Settings > Privacy > Camera\" and enable XXTouch to use your camera.")];
                [alertView addButtonWithTitle:XXLString(@"OK") type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                    
                }];
                [alertView show];
            });
        } else if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async_on_main_queue(^{
                        [self loadLayerFrame];
                    });
                } else {
                    dispatch_async_on_main_queue(^{
                        self.title = XXLString(@"Access Denied");
                        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:XXLString(@"Access Denied")
                                                                         andMessage:XXLString(@"Turn to \"Settings > Privacy > Camera\" and enable XXTouch to use your camera.")];
                        [alertView addButtonWithTitle:XXLString(@"OK") type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                            
                        }];
                        [alertView show];
                    });
                }
            }];
        }
    });
}

- (UIImage *)maskImage {
    if (!_maskImage) {
        
        CGSize size = self.navigationController.view.size;
        CGFloat rectWidth = size.width / 3 * 2;
        
        CGPoint pA = CGPointMake(size.width / 2 - rectWidth / 2, size.height / 2 - rectWidth / 2);
        CGPoint pD = CGPointMake(size.width / 2 + rectWidth / 2, size.height / 2 + rectWidth / 2);
        
        // Begin Context
        UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        // Fill Background
        CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.3f);
        CGRect drawRect = CGRectMake(0, 0, size.width, size.height);
        CGContextFillRect(ctx, drawRect);
        
        // Clear Rect
        CGRect cropRect = CGRectMake(pA.x, pA.y, rectWidth, rectWidth);
        CGContextClearRect(ctx, cropRect);
        
        // Draw Rect Lines
        CGContextSetLineWidth(ctx, 1.6f);
        CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
        CGContextAddRect(ctx, cropRect);
        CGContextStrokePath(ctx);
        
        // Draw Rect Angles
        CGFloat lineWidthAngle = 8.f;
        CGFloat diffAngle = lineWidthAngle / 3;
        CGFloat wAngle = 24.f;
        CGFloat hAngle = 24.f;
        CGFloat leftX = pA.x - diffAngle;
        CGFloat topY = pA.y - diffAngle;
        CGFloat rightX = pD.x + diffAngle;
        CGFloat bottomY = pD.y + diffAngle;
        
        CGContextSetLineWidth(ctx, lineWidthAngle);
        CGContextSetStrokeColorWithColor(ctx, STYLE_TINT_COLOR.CGColor);
        
        CGContextMoveToPoint(ctx, leftX - lineWidthAngle / 2, topY);
        CGContextAddLineToPoint(ctx, leftX + wAngle, topY);
        CGContextMoveToPoint(ctx, leftX, topY - lineWidthAngle / 2);
        CGContextAddLineToPoint(ctx, leftX, topY + hAngle);
        CGContextMoveToPoint(ctx, leftX - lineWidthAngle / 2, bottomY);
        CGContextAddLineToPoint(ctx, leftX + wAngle, bottomY);
        CGContextMoveToPoint(ctx, leftX, bottomY + lineWidthAngle / 2);
        CGContextAddLineToPoint(ctx, leftX, bottomY - hAngle);
        CGContextMoveToPoint(ctx, rightX + lineWidthAngle / 2, topY);
        CGContextAddLineToPoint(ctx, rightX - wAngle, topY);
        CGContextMoveToPoint(ctx, rightX, topY - lineWidthAngle / 2);
        CGContextAddLineToPoint(ctx, rightX, topY + hAngle);
        CGContextMoveToPoint(ctx, rightX + lineWidthAngle / 2, bottomY);
        CGContextAddLineToPoint(ctx, rightX - wAngle, bottomY);
        CGContextMoveToPoint(ctx, rightX, bottomY + lineWidthAngle / 2);
        CGContextAddLineToPoint(ctx, rightX, bottomY - hAngle);
        CGContextStrokePath(ctx);
        
        // Generate Image
        UIImage* returnImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        _maskImage = returnImage;
        _cropRect = cropRect;
    }
    return _maskImage;
}

- (UIImageView *)maskView {
    if (!_maskView) {
        UIImageView *maskView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        maskView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.f];
        maskView.image = self.maskImage;
        maskView.contentMode = UIViewContentModeCenter;
        _maskView = maskView;
    }
    return _maskView;
}

- (void)loadLayerFrame {
    if (!self.layerLoaded) {
        self.layerLoaded = YES;
        self.layer.frame = self.view.layer.bounds;
        [self.view.layer insertSublayer:self.layer atIndex:0];
        [self.session startRunning];
    }
}

- (void)close:(UIBarButtonItem *)sender {
    if (_session) {
        [_session stopRunning];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)album:(UIBarButtonItem *)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [self.navigationController.view makeToast:@"Source type unavailable: UIImagePickerControllerSourceTypePhotoLibrary"];
        return;
    }
    if (_session) {
        [_session stopRunning];
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[ (NSString *)kUTTypeImage ];
    picker.delegate = self;
    picker.allowsEditing = NO;
    [self.navigationController presentViewController:picker animated:YES completion:^() {
        
    }];
}

- (void)closeAuth:(UIBarButtonItem *)sender {
    [self.authController dismissViewControllerAnimated:YES completion:^() {
        [self performSelector:@selector(continueScanning) withObject:nil afterDelay:.6f];
    }];
}

- (void)closeWeb:(UIBarButtonItem *)sender {
    [self.webController dismissViewControllerAnimated:YES completion:^() {
        [self performSelector:@selector(continueScanning) withObject:nil afterDelay:.6f];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.layerLoaded = NO;
    
    self.view.backgroundColor = [UIColor blackColor];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    self.navigationItem.leftBarButtonItem = self.closeItem;
    self.navigationItem.rightBarButtonItem = self.albumItem;
    [self.view addSubview:self.maskView];
    self.title = XXLString(@"Scan QR Code");
    
    [self fetchPermission];
}

- (void)dealloc {
    CYLog(@"");
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject * metadataObject = metadataObjects[0];
        CYLog(@"%@", metadataObject.stringValue);
        if (_session && [_session isRunning]) {
            [_session stopRunning];
        }
        [self handleOutput:metadataObject.stringValue];
    }
}

- (void)continueScanning {
    if (_session && ![_session isRunning]) {
        [_session startRunning];
    }
}

- (void)redirectingToUrl:(NSURL *)url {
    XXEmptyNavigationController *navController = [[[AppDelegate globalDelegate] rootViewController].storyboard instantiateViewControllerWithIdentifier:kXXNavigationControllerStoryboardID];
    XXWebViewController *webController = (XXWebViewController *)navController.topViewController;
    webController.url = url;
    webController.title = XXLString(@"Redirecting...");
    _webController = webController;
    webController.navigationItem.leftBarButtonItem = self.closeWebItem;
    [self.navigationController presentViewController:navController animated:YES completion:^() {
        
    }];
}

- (void)codeBindingToController:(NSString *)code {
    XXAuthorizationTableViewController *authController = (XXAuthorizationTableViewController *)[[[AppDelegate globalDelegate] rootViewController].storyboard instantiateViewControllerWithIdentifier:kXXAuthorizationTableViewControllerStoryboardID];
    authController.code = code;
    _authController = authController;
    authController.navigationItem.leftBarButtonItem = self.closeAuthItem;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:authController];
    navController.navigationBar.barTintColor = STYLE_TINT_COLOR;
    [self.navigationController presentViewController:navController animated:YES completion:^() {
        
    }];
}

- (NSString *)scanImage:(UIImage *)image {
    NSString *scannedResult = nil;
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        
    } else {
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        for (int index = 0; index < features.count; index ++) {
            CIQRCodeFeature *feature = features[index];
            scannedResult = feature.messageString;
            if (scannedResult) {
                CYLog(@"%@", scannedResult);
                break;
            }
        }
    }
    return scannedResult;
}

- (void)confirmDownloadingTask:(NSDictionary *)downloadObj {
    UINavigationController *navController = [[[AppDelegate globalDelegate] rootViewController].storyboard instantiateViewControllerWithIdentifier:kXXDownloadTaskNavigationControllerStoryboardID];
    XXScanDownloadTaskViewController *downloadController = (XXScanDownloadTaskViewController *)navController.topViewController;
    downloadController.sourceUrl = downloadObj[@"url"];
    downloadController.destinationUrl = downloadObj[@"path"];
    downloadController.delegate = self;
    [self.navigationController presentViewController:navController animated:YES completion:^{
        
    }];
}

- (void)handleOutput:(NSString *)output {
    if (!output) return;
    // Judge Content
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    
    // URL?
    NSURL *url = [NSURL URLWithString:output];
    if (url) {
        [self.navigationController.view hideToastActivity];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [self.navigationController.view makeToast:XXLString(@"Redirecting to url...")];
            [self performSelector:@selector(redirectingToUrl:) withObject:url afterDelay:2.f];
        } else {
            [self.navigationController.view makeToast:XXLString(@"Invalid url")];
            [self performSelector:@selector(continueScanning) withObject:nil afterDelay:2.f];
        }
        return;
    }
    
    // JSON?
    id jsonObj = [output jsonValueDecoded];
    if (jsonObj) {
        [self.navigationController.view hideToastActivity];
        if ([jsonObj isKindOfClass:[NSDictionary class]]) {
            NSString *event = [jsonObj objectForKey:@"event"];
            if ([event isEqualToString:@"bind_code"]) {
                NSString *code = [jsonObj objectForKey:@"code"];
                [self.navigationController.view makeToast:XXLString(@"Binding code...")];
                [self performSelector:@selector(codeBindingToController:) withObject:code afterDelay:2.f];
            } else if ([event isEqualToString:@"down_script"]) {
                [self.navigationController.view makeToast:XXLString(@"Download Task...")];
                [self performSelector:@selector(confirmDownloadingTask:) withObject:jsonObj afterDelay:2.f];
            } else {
                [self.navigationController.view makeToast:XXLString(@"Invalid event")];
                [self performSelector:@selector(continueScanning) withObject:nil afterDelay:2.f];
            }
        }
        return;
    }
    
    // PLAIN TEXT?
    [self.navigationController.view hideToastActivity];
    [[UIPasteboard generalPasteboard] setString:output];
    [self.navigationController.view makeToast:XXLString(@"Text copied to the pasteboard")];
    [self performSelector:@selector(continueScanning) withObject:nil afterDelay:2.f];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        [self performSelector:@selector(continueScanning) withObject:nil afterDelay:.6f];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        @weakify(self);
        [self.navigationController.view makeToastActivity:CSToastPositionCenter];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            @strongify(self);
            NSString *scannedResult = [self scanImage:originalImage];
            dispatch_async_on_main_queue(^{
                [self.navigationController.view hideToastActivity];
                if (!scannedResult) {
                    [self.navigationController.view makeToast:XXLString(@"Cannot find QR Code in that image")];
                    [self performSelector:@selector(continueScanning) withObject:nil afterDelay:2.f];
                } else {
                    [self handleOutput:scannedResult];
                }
            });
        });
    }
}

- (void)confirmDownloadTask:(XXScanDownloadTaskViewController *)vc
                     source:(NSString *)sourcePath
                destination:(NSString *)destinationPath {
    [vc dismissViewControllerAnimated:YES completion:nil];
    
    self.navigationController.view.userInteractionEnabled = NO;
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:sourcePath];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *err) {
        NSError *error = nil;
        if (!err) {
            [FCFileManager moveItemAtPath:[location path] toPath:[destinationPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] error:&error];
        } else {
            error = err;
        }
        dispatch_async_on_main_queue(^{
            [self.navigationController.view hideToastActivity];
            self.navigationController.view.userInteractionEnabled = YES;
            if (error == nil) {
                [self.navigationController.view makeToast:XXLString(@"Download Task Completed")];
                [self performSelector:@selector(close:) withObject:nil afterDelay:.6f];
            } else {
                [self.navigationController.view makeToast:[error localizedDescription]];
                [self performSelector:@selector(continueScanning) withObject:nil afterDelay:.6f];
            }
        });
    }];
    [task resume];
}

- (void)cancelDownloadTask:(XXScanDownloadTaskViewController *)vc {
    [vc dismissViewControllerAnimated:YES completion:^{
        [self performSelector:@selector(continueScanning) withObject:nil afterDelay:.6f];
    }];
}

@end
