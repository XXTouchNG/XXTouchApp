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
@property (weak, nonatomic) IBOutlet UISwitch *syntaxHighlightSwitch;

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
        XXEditorFontSettingsTableViewController *fontController = [[UIStoryboard storyboardWithName:@"XXBaseTextEditor" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:kXXEditorFontSettingsTableViewControllerStoryboardID];
        fontController.delegate = self;
        [self.navigationController pushViewController:fontController animated:YES];
    }
}

- (void)loadSettings {
    self.fontNameLabel.text = [XXTGSSI.dataService fontFamilyName];
    self.syntaxHighlightSwitch.on = [XXTGSSI.dataService syntaxHighlightingEnabled];
    
    self.lineNumbersSwitch.on = [XXTGSSI.dataService lineNumbersEnabled];
    self.softTabsSwitch.on = [XXTGSSI.dataService softTabsEnabled];
    self.autoIndentSwitch.on = [XXTGSSI.dataService autoIndentEnabled];
    self.readOnlySwitch.on = [XXTGSSI.dataService readOnlyEnabled];
    self.autoCorrectionSwitch.on = [XXTGSSI.dataService autoCorrectionEnabled];
    self.autoCapitalizationSwitch.on = [XXTGSSI.dataService autoCapitalizationEnabled];
    
    self.tabWidthControl.selectedSegmentIndex = [XXTGSSI.dataService tabWidth];
    self.fontSizeView.fontSize = (NSUInteger)[XXTGSSI.dataService fontFamilySize];
    
    self.regexSwitch.on = [XXTGSSI.dataService regexSearchingEnabled];
    self.caseSensitiveSwitch.on = [XXTGSSI.dataService caseSensitiveEnabled];
}

- (IBAction)lineNumbersChanged:(UISwitch *)sender {
    [XXTGSSI.dataService setLineNumbersEnabled:sender.on]; [self notifyChangedInSection:1];
}

- (IBAction)tabWidthChanged:(UISegmentedControl *)sender {
    [XXTGSSI.dataService setTabWidth:sender.selectedSegmentIndex]; [self notifyChangedInSection:2];
}

- (IBAction)autoIndentChanged:(UISwitch *)sender {
    [XXTGSSI.dataService setAutoIndentEnabled:sender.on]; [self notifyChangedInSection:2];
}

- (IBAction)softTabsChanged:(UISwitch *)sender {
    [XXTGSSI.dataService setSoftTabsEnabled:sender.on]; [self notifyChangedInSection:2];
}

- (IBAction)readOnlyChanged:(UISwitch *)sender {
    [XXTGSSI.dataService setReadOnlyEnabled:sender.on]; [self notifyChangedInSection:3];
}

- (IBAction)autoCorrectionChanged:(UISwitch *)sender {
    [XXTGSSI.dataService setAutoCorrectionEnabled:sender.on]; [self notifyChangedInSection:3];
}

- (IBAction)autoCapitalizationChanged:(UISwitch *)sender {
    [XXTGSSI.dataService setAutoCapitalizationEnabled:sender.on]; [self notifyChangedInSection:3];
}

- (IBAction)regexChanged:(UISwitch *)sender {
    [XXTGSSI.dataService setRegexSearchingEnabled:sender.on]; [self notifyChangedInSection:4];
}

- (IBAction)caseSensitiveChanged:(UISwitch *)sender {
    [XXTGSSI.dataService setCaseSensitiveEnabled:sender.on]; [self notifyChangedInSection:4];
}

- (IBAction)syntaxHighlightChanged:(UISwitch *)sender {
    [XXTGSSI.dataService setSyntaxHighlightingEnabled:sender.on]; [self notifyChangedInSection:1];
}

- (void)notifyChangedInSection:(NSUInteger)section {
    if (_delegate && [_delegate respondsToSelector:@selector(editorSettingsDidEdited:inSection:)])
    {
        [_delegate editorSettingsDidEdited:self inSection:section];
    }
}

- (void)editorFontSettingsDidEdited:(XXEditorFontSettingsTableViewController *)controller {
    self.fontNameLabel.text = [XXTGSSI.dataService fontFamilyName];
    [self notifyChangedInSection:0];
}

- (void)fontViewSizeDidChanged:(XXEditorFontSizeView *)view {
    [XXTGSSI.dataService setFontFamilySize:(CGFloat)view.fontSize];
    [self notifyChangedInSection:0];
}

- (void)dealloc {
    XXLog(@"");
}

@end
