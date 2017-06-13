//
//  XXTKeyEventPicker.m
//  XXTPickerCollection
//
//  Created by Zheng on 30/04/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTKeyEventPicker.h"
#import "XXTKeyEvent.h"
#import "XXTPickerHelper.h"
#import "XXTPickerDefine.h"

static NSString * const kXXTKeyEventTableViewCellReuseIdentifier = @"kXXTKeyEventTableViewCellReuseIdentifier";

@interface XXTKeyEventPicker () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) NSArray <NSArray <XXTKeyEvent *> *> *events;
@property (nonatomic, strong) NSArray <NSString *> *sectionNames;
@property (nonatomic, strong) NSIndexPath *lastSelected;

@end

@implementation XXTKeyEventPicker {
    XXTPickerTask *_pickerTask;
    NSString *_pickerSubtitle;
}

@synthesize pickerTask = _pickerTask;

#pragma mark - XXTBasePicker

+ (NSString *)pickerKeyword {
    return @"@key@";
}

- (NSString *)pickerResult {
    return self.events[(NSUInteger) self.lastSelected.section][(NSUInteger) self.lastSelected.row].command;
}

#pragma mark - Default Style

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (NSString *)title {
    return NSLocalizedStringFromTableInBundle(@"Key Event", nil, [XXTPickerHelper bundle], nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.lastSelected = [NSIndexPath indexPathForRow:0 inSection:0];
    self.sectionNames = @[
            NSLocalizedStringFromTableInBundle(@"Hardware Keys", nil, [XXTPickerHelper bundle], nil),
            NSLocalizedStringFromTableInBundle(@"Keyboard Keys", nil, [XXTPickerHelper bundle], nil),
            NSLocalizedStringFromTableInBundle(@"Media Keys", nil, [XXTPickerHelper bundle], nil),
    ];
    self.events = @[
            @[
                    [XXTKeyEvent eventWithTitle:NSLocalizedStringFromTableInBundle(@"Home Button", nil, [XXTPickerHelper bundle], nil) command:@"HOMEBUTTON"],
                    [XXTKeyEvent eventWithTitle:NSLocalizedStringFromTableInBundle(@"Volume +", nil, [XXTPickerHelper bundle], nil) command:@"VOLUMEUP"],
                    [XXTKeyEvent eventWithTitle:NSLocalizedStringFromTableInBundle(@"Volume -", nil, [XXTPickerHelper bundle], nil) command:@"VOLUMEDOWN"],
                    [XXTKeyEvent eventWithTitle:NSLocalizedStringFromTableInBundle(@"Power Button", nil, [XXTPickerHelper bundle], nil) command:@"LOCK"],
                    [XXTKeyEvent eventWithTitle:NSLocalizedStringFromTableInBundle(@"Mute Button", nil, [XXTPickerHelper bundle], nil) command:@"MUTE"],
            ],
            @[

                    [XXTKeyEvent eventWithTitle:NSLocalizedStringFromTableInBundle(@"Return Key", nil, [XXTPickerHelper bundle], nil) command:@"RETURN"],
                    [XXTKeyEvent eventWithTitle:NSLocalizedStringFromTableInBundle(@"Esc Key", nil, [XXTPickerHelper bundle], nil) command:@"ESCAPE"],
                    [XXTKeyEvent eventWithTitle:NSLocalizedStringFromTableInBundle(@"Backspace Key", nil, [XXTPickerHelper bundle], nil) command:@"BACKSPACE"],
                    [XXTKeyEvent eventWithTitle:NSLocalizedStringFromTableInBundle(@"Space Key", nil, [XXTPickerHelper bundle], nil) command:@"SPACE"],
                    [XXTKeyEvent eventWithTitle:NSLocalizedStringFromTableInBundle(@"Tab Key", nil, [XXTPickerHelper bundle], nil) command:@"TAB"],
                    [XXTKeyEvent eventWithTitle:NSLocalizedStringFromTableInBundle(@"Spotlight Key", nil, [XXTPickerHelper bundle], nil) command:@"SPOTLIGHT"],
                    [XXTKeyEvent eventWithTitle:NSLocalizedStringFromTableInBundle(@"Bright +", nil, [XXTPickerHelper bundle], nil) command:@"BRIGHTUP"],
                    [XXTKeyEvent eventWithTitle:NSLocalizedStringFromTableInBundle(@"Bright -", nil, [XXTPickerHelper bundle], nil) command:@"BRIGHTDOWN"],
                    [XXTKeyEvent eventWithTitle:NSLocalizedStringFromTableInBundle(@"Show/Hide Keyboard", nil, [XXTPickerHelper bundle], nil) command:@"SHOW_HIDE_KEYBOARD"],
            ],
            @[
                    [XXTKeyEvent eventWithTitle:NSLocalizedStringFromTableInBundle(@"Media Forward Key", nil, [XXTPickerHelper bundle], nil) command:@"FORWARD"],
                    [XXTKeyEvent eventWithTitle:NSLocalizedStringFromTableInBundle(@"Media Rewind Key", nil, [XXTPickerHelper bundle], nil) command:@"REWIND"],
                    [XXTKeyEvent eventWithTitle:NSLocalizedStringFromTableInBundle(@"Media Forward 2 Key", nil, [XXTPickerHelper bundle], nil) command:@"FORWARD2"],
                    [XXTKeyEvent eventWithTitle:NSLocalizedStringFromTableInBundle(@"Media Rewind 2 Key", nil, [XXTPickerHelper bundle], nil) command:@"REWIND2"],
                    [XXTKeyEvent eventWithTitle:NSLocalizedStringFromTableInBundle(@"Media Play/Pause Key", nil, [XXTPickerHelper bundle], nil) command:@"PLAYPAUSE"],
            ]
    ];

    self.view.backgroundColor = [UIColor whiteColor];

    UITableView * tableView1 = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView1.delegate = self;
    tableView1.dataSource = self;
    tableView1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    START_IGNORE_PARTIAL
    if (XXTP_SYSTEM_9) {
        tableView1.cellLayoutMarginsFollowReadableWidth = NO;
    }
    END_IGNORE_PARTIAL
    self.tableView = tableView1;

    [self.view addSubview:tableView1];

    [self.pickerTask nextStep];
    UIBarButtonItem *rightItem = NULL;
    if ([self.pickerTask taskFinished]) {
        rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(taskFinished:)];
    } else {
        rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Next", nil, [XXTPickerHelper bundle], nil) style:UIBarButtonItemStylePlain target:self action:@selector(taskNextStep:)];
    }
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateSubtitle:NSLocalizedStringFromTableInBundle(@"Select a key event", nil, [XXTPickerHelper bundle], nil)];
}

#pragma mark - Task Operations

- (void)taskFinished:(UIBarButtonItem *)sender {
    [[XXTPickerHelper sharedInstance] performFinished:self];
}

- (void)taskNextStep:(UIBarButtonItem *)sender {
    [[XXTPickerHelper sharedInstance] performNextStep:self];
}

- (void)updateSubtitle:(NSString *)subtitle {
    _pickerSubtitle = subtitle;
    [[XXTPickerHelper sharedInstance] performUpdateStep:self];
}

- (NSString *)pickerSubtitle {
    return _pickerSubtitle;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.events.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionNames[(NSUInteger) section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events[(NSUInteger) section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kXXTKeyEventTableViewCellReuseIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kXXTKeyEventTableViewCellReuseIdentifier];
    }
    XXTKeyEvent *keyEvent = self.events[(NSUInteger) indexPath.section][(NSUInteger) indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", keyEvent.title, keyEvent.command];
    cell.textLabel.font = [UIFont fontWithName:@"CourierNewPSMT" size:16.0f];
    cell.tintColor = [[XXTPickerHelper sharedInstance] frontColor];
    if (self.lastSelected &&
            self.lastSelected.section == indexPath.section &&
            self.lastSelected.row == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.lastSelected) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.lastSelected];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    self.lastSelected = indexPath;
    UITableViewCell *cell1 = [tableView cellForRowAtIndexPath:indexPath];
    cell1.accessoryType = UITableViewCellAccessoryCheckmark;
    [self updateSubtitle:cell1.textLabel.text];
}

#pragma mark - Memory

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"[XXTKeyEventPicker dealloc]");
#endif
}

@end
