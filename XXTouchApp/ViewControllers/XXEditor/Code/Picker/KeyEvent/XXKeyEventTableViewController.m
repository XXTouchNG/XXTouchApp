//
//  XXKeyEventTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXKeyEventTableViewController.h"
#import "XXKeyEventModel.h"
#import "XXKeyEventTableViewCell.h"
#import "XXCodeMakerService.h"

static NSString * const kXXKeyEventTableViewCellReuseIdentifier = @"kXXKeyEventTableViewCellReuseIdentifier";

@interface XXKeyEventTableViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray <XXKeyEventModel *> *keyEvents;
@property (nonatomic, strong) NSArray <XXKeyEventModel *> *softKeyEvents;
@property (nonatomic, strong) NSArray <XXKeyEventModel *> *mediaKeyEvents;
@property (nonatomic, strong) NSArray <NSArray <XXKeyEventModel *> *> *events;
@property (nonatomic, strong) NSArray <NSString *> *sectionNames;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation XXKeyEventTableViewController {
    NSString *_previewString;
}

+ (NSString *)keyword {
    return @"@key@";
}

+ (NSString *)storyboardID {
    return kXXKeyEventTableViewControllerStoryboardID;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _previewString = nil;
    self.title = NSLocalizedString(@"Key Event", nil);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

#pragma mark - Events

- (NSArray <XXKeyEventModel *> *)keyEvents {
    if (!_keyEvents) {
        _keyEvents = @[
                       [XXKeyEventModel modelWithTitle:NSLocalizedString(@"Home Button", nil) command:@"HOMEBUTTON"],
                       [XXKeyEventModel modelWithTitle:NSLocalizedString(@"Volume +", nil) command:@"VOLUMEUP"],
                       [XXKeyEventModel modelWithTitle:NSLocalizedString(@"Volume -", nil) command:@"VOLUMEDOWN"],
                       [XXKeyEventModel modelWithTitle:NSLocalizedString(@"Power Button", nil) command:@"LOCK"],
                       [XXKeyEventModel modelWithTitle:NSLocalizedString(@"Mute Button", nil) command:@"MUTE"],
                       ];
    }
    return _keyEvents;
}

- (NSArray <XXKeyEventModel *> *)softKeyEvents {
    if (!_softKeyEvents) {
        _softKeyEvents = @[
                           
                           [XXKeyEventModel modelWithTitle:NSLocalizedString(@"Return Key", nil) command:@"RETURN"],
                           [XXKeyEventModel modelWithTitle:NSLocalizedString(@"Esc Key", nil) command:@"ESCAPE"],
                           [XXKeyEventModel modelWithTitle:NSLocalizedString(@"Backspace Key", nil) command:@"BACKSPACE"],
                           [XXKeyEventModel modelWithTitle:NSLocalizedString(@"Space Key", nil) command:@"SPACE"],
                           [XXKeyEventModel modelWithTitle:NSLocalizedString(@"Tab Key", nil) command:@"TAB"],
                           [XXKeyEventModel modelWithTitle:NSLocalizedString(@"Spotlight Key", nil) command:@"SPOTLIGHT"],
                           [XXKeyEventModel modelWithTitle:NSLocalizedString(@"Bright +", nil) command:@"BRIGHTUP"],
                           [XXKeyEventModel modelWithTitle:NSLocalizedString(@"Bright -", nil) command:@"BRIGHTDOWN"],
                           [XXKeyEventModel modelWithTitle:NSLocalizedString(@"Show/Hide Keyboard", nil) command:@"SHOW_HIDE_KEYBOARD"],
                           ];
    }
    return _softKeyEvents;
}

- (NSArray <XXKeyEventModel *> *)mediaKeyEvents {
    if (!_mediaKeyEvents) {
        _mediaKeyEvents = @[
                            [XXKeyEventModel modelWithTitle:NSLocalizedString(@"Media Forward Key", nil) command:@"FORWARD"],
                            [XXKeyEventModel modelWithTitle:NSLocalizedString(@"Media Rewind Key", nil) command:@"REWIND"],
                            [XXKeyEventModel modelWithTitle:NSLocalizedString(@"Media Forward 2 Key", nil) command:@"FORWARD2"],
                            [XXKeyEventModel modelWithTitle:NSLocalizedString(@"Media Rewind 2 Key", nil) command:@"REWIND2"],
                            [XXKeyEventModel modelWithTitle:NSLocalizedString(@"Media Play/Pause Key", nil) command:@"PLAYPAUSE"],
                            ];
    }
    return _mediaKeyEvents;
}

- (NSArray <NSArray <XXKeyEventModel *> *> *)events {
    if (!_events) {
        _events = @[self.keyEvents, self.softKeyEvents, self.mediaKeyEvents];
    }
    return _events;
}

- (NSArray <NSString *> *)sectionNames {
    if (!_sectionNames) {
        _sectionNames = @[
                          NSLocalizedString(@"Hardware Keys", nil),
                          NSLocalizedString(@"Keyboard Keys", nil),
                          NSLocalizedString(@"Media Keys", nil),
                          ];
    }
    return _sectionNames;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.events.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionNames[(NSUInteger) section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)self.events[(NSUInteger) section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XXKeyEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kXXKeyEventTableViewCellReuseIdentifier forIndexPath:indexPath];
    cell.keyEvent = self.events[(NSUInteger) indexPath.section][(NSUInteger) indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", cell.keyEvent.title, cell.keyEvent.command];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _previewString = ((XXKeyEventModel *)((NSArray *)self.events[(NSUInteger) indexPath.section])[(NSUInteger) indexPath.row]).command;
    [self pushToNextControllerWithKeyword:[[self class] keyword] replacement:self.previewString];
}

#pragma mark - Previewing Bar

- (NSString *)previewString {
    return _previewString;
}

- (NSString *)subtitle {
    return NSLocalizedString(@"Select a key event", nil);
}

@end
