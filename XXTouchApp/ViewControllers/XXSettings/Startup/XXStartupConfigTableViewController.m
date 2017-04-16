//
//  XXStartupConfigTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/13/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXStartupConfigTableViewController.h"
#import "XXScriptListTableViewController.h"
#import "XXLocalNetService.h"
#import "XXLocalDataService.h"

@interface XXStartupConfigTableViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *startupSwitch;
@property (weak, nonatomic) IBOutlet UILabel *bootScriptPathLabel;

@end

@implementation XXStartupConfigTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    SendConfigAction([XXLocalNetService localGetStartUpConfWithError:&err], [self loadStartupConfig]);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadStartupConfig];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadStartupConfig {
    BOOL switchedOn = [XXTGSSI.dataService startUpConfigSwitch];
    self.startupSwitch.on = switchedOn;
    if (switchedOn) {
        self.bootScriptPathLabel.textColor = STYLE_TINT_COLOR;
    } else {
        self.bootScriptPathLabel.textColor = [UIColor grayColor];
    }
    NSString *selectedBootScript = [XXTGSSI.dataService startUpConfigScriptPath];
    if (selectedBootScript && selectedBootScript.length != 0) {
        self.bootScriptPathLabel.text = selectedBootScript;
    }
}

- (IBAction)enableBootScriptSwitchChanged:(UISwitch *)sender {
    if (sender.on) {
        SendConfigAction([XXLocalNetService localSetStartUpRunOnWithError:&err], [self loadStartupConfig]);
    } else {
        SendConfigAction([XXLocalNetService localSetStartUpRunOffWithError:&err], [self loadStartupConfig]);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 0) {
        XXScriptListTableViewController *newController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:kXXScriptListTableViewControllerStoryboardID];
        newController.type = XXScriptListTableViewControllerTypeBootscript;
        newController.selectViewController = self;
        newController.title = NSLocalizedString(@"Select Bootscript", nil);
        [self.navigationController pushViewController:newController animated:YES];
    }
}

- (void)dealloc {
    XXLog(@"");
}

@end
