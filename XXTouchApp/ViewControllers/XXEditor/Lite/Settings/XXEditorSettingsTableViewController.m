//
//  XXEditorSettingsTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 01/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXEditorSettingsTableViewController.h"
#import "XXLocalDataService.h"
#import "XXEditorFontSettingsTableViewController.h"
#import "XXEditorFontSizeView.h"

@interface XXEditorSettingsTableViewController () <XXEditorFontSizeViewDelegate, XXEditorFontSettingsTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *fontNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *lineNumbersSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tabWidthControl;
@property (weak, nonatomic) IBOutlet UISwitch *softTabsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *readOnlySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoCorrectionSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoCapitalizationSwitch;
@property (weak, nonatomic) IBOutlet XXEditorFontSizeView *fontSizeView;
@property (weak, nonatomic) IBOutlet UISwitch *autoIndentSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *regexSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *caseSensitiveSwitch;

@end

@implementation XXEditorSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fontSizeView.delegate = self;
    self.clearsSelectionOnViewWillAppear = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadSettings];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        XXEditorFontSettingsTableViewController *fontController = [self.storyboard instantiateViewControllerWithIdentifier:kXXEditorFontSettingsTableViewControllerStoryboardID];
        fontController.delegate = self;
        [self.navigationController pushViewController:fontController animated:YES];
    }
}

- (void)loadSettings {
    self.fontNameLabel.text = [[XXLocalDataService sharedInstance] fontFamilyName];
    
    self.lineNumbersSwitch.on = [[XXLocalDataService sharedInstance] lineNumbersEnabled];
    self.softTabsSwitch.on = [[XXLocalDataService sharedInstance] softTabsEnabled];
    self.autoIndentSwitch.on = [[XXLocalDataService sharedInstance] autoIndentEnabled];
    self.readOnlySwitch.on = [[XXLocalDataService sharedInstance] readOnlyEnabled];
    self.autoCorrectionSwitch.on = [[XXLocalDataService sharedInstance] autoCorrectionEnabled];
    self.autoCapitalizationSwitch.on = [[XXLocalDataService sharedInstance] autoCapitalizationEnabled];
    
    self.tabWidthControl.selectedSegmentIndex = [[XXLocalDataService sharedInstance] tabWidth];
    self.fontSizeView.fontSize = (NSUInteger)[[XXLocalDataService sharedInstance] fontFamilySize];
    
    self.regexSwitch.on = [[XXLocalDataService sharedInstance] regexSearchingEnabled];
    self.caseSensitiveSwitch.on = [[XXLocalDataService sharedInstance] caseSensitiveEnabled];
}

- (IBAction)lineNumbersChanged:(UISwitch *)sender {
    [[XXLocalDataService sharedInstance] setLineNumbersEnabled:sender.on]; [self notifyChangedInSection:1];
}

- (IBAction)tabWidthChanged:(UISegmentedControl *)sender {
    [[XXLocalDataService sharedInstance] setTabWidth:sender.selectedSegmentIndex]; [self notifyChangedInSection:2];
}

- (IBAction)autoIndentChanged:(UISwitch *)sender {
    [[XXLocalDataService sharedInstance] setAutoIndentEnabled:sender.on]; [self notifyChangedInSection:2];
}

- (IBAction)softTabsChanged:(UISwitch *)sender {
    [[XXLocalDataService sharedInstance] setSoftTabsEnabled:sender.on]; [self notifyChangedInSection:2];
}

- (IBAction)readOnlyChanged:(UISwitch *)sender {
    [[XXLocalDataService sharedInstance] setReadOnlyEnabled:sender.on]; [self notifyChangedInSection:3];
}

- (IBAction)autoCorrectionChanged:(UISwitch *)sender {
    [[XXLocalDataService sharedInstance] setAutoCorrectionEnabled:sender.on]; [self notifyChangedInSection:3];
}

- (IBAction)autoCapitalizationChanged:(UISwitch *)sender {
    [[XXLocalDataService sharedInstance] setAutoCapitalizationEnabled:sender.on]; [self notifyChangedInSection:3];
}

- (IBAction)regexChanged:(UISwitch *)sender {
    [[XXLocalDataService sharedInstance] setRegexSearchingEnabled:sender.on]; [self notifyChangedInSection:4];
}

- (IBAction)caseSensitiveChanged:(UISwitch *)sender {
    [[XXLocalDataService sharedInstance] setCaseSensitiveEnabled:sender.on]; [self notifyChangedInSection:4];
}

- (void)notifyChangedInSection:(NSUInteger)section {
    if (_delegate && [_delegate respondsToSelector:@selector(editorSettingsDidEdited:inSection:)])
    {
        [_delegate editorSettingsDidEdited:self inSection:section];
    }
}

- (void)editorFontSettingsDidEdited:(XXEditorFontSettingsTableViewController *)controller {
    self.fontNameLabel.text = [[XXLocalDataService sharedInstance] fontFamilyName];
    [self notifyChangedInSection:0];
}

- (void)fontViewSizeDidChanged:(XXEditorFontSizeView *)view {
    [[XXLocalDataService sharedInstance] setFontFamilySize:(CGFloat)view.fontSize];
    [self notifyChangedInSection:0];
}

- (void)dealloc {
    CYLog(@"");
}

@end
