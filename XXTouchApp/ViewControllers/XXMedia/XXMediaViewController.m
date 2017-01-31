//
//  XXMediaViewController.m
//  XXTouchApp
//
//  Created by Zheng on 14/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXMediaViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface XXMediaViewController ()

@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) UIBarButtonItem *closeItem;
@property (nonatomic, strong) UIBarButtonItem *shareItem;

@end

@implementation XXMediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [self.filePath lastPathComponent];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.leftBarButtonItem = self.closeItem;
    self.navigationItem.rightBarButtonItem = self.shareItem;
    [self.view addSubview:self.moviePlayer.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    
}

#pragma mark - Notifications

- (void)moviePlaybackDidFinish:(NSNotification *)aNotification {
    NSDictionary *userInfo = aNotification.userInfo;
    if ([userInfo[@"error"] isKindOfClass:[NSError class]]) {
        NSString *reason = [userInfo[@"error"] localizedDescription];
        [self.navigationController.view makeToast:reason];
    }
}

#pragma mark - Getters

- (MPMoviePlayerController *)moviePlayer {
    if (!_moviePlayer) {
        NSURL *urlString = [NSURL fileURLWithPath:self.filePath];
        MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:urlString];
        moviePlayer.view.frame = self.view.bounds;
        moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        moviePlayer.view.backgroundColor = [UIColor whiteColor];
        moviePlayer.shouldAutoplay = NO;
        [moviePlayer setControlStyle:MPMovieControlStyleEmbedded];
        [moviePlayer prepareToPlay];
        _moviePlayer = moviePlayer;
    }
    return _moviePlayer;
}

- (UIBarButtonItem *)closeItem {
    if (!_closeItem) {
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(closeItemTapped:)];
        closeItem.tintColor = [UIColor whiteColor];
        _closeItem = closeItem;
    }
    return _closeItem;
}

- (UIBarButtonItem *)shareItem {
    if (!_shareItem) {
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareItemTapped:) ];
        anotherButton.tintColor = [UIColor whiteColor];
        _shareItem = anotherButton;
    }
    return _shareItem;
}

#pragma mark - Actions

- (void)closeItemTapped:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^() {
        if (self.activity && !self.activity.activeDirectly) {
            [self.activity activityDidFinish:YES];
        }
    }];
}

- (void)shareItemTapped:(UIBarButtonItem *)sender {
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:self.filePath]] applicationActivities:nil];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIView* view = [sender valueForKey:@"view"];
        controller.popoverPresentationController.sourceView = view;
    }
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

@end
