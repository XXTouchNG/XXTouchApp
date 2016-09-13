//
//  XXStartupConfigTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/13/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXStartupConfigTableViewController.h"
#import "XXLocalNetService.h"
#import "XXLocalDataService.h"

@interface XXStartupConfigTableViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *startupSwitch;
@property (weak, nonatomic) IBOutlet UILabel *bootScriptPathLabel;

@end

@implementation XXStartupConfigTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SendConfigAction([XXLocalNetService localGetStartUpConfWithError:&err], [self loadStartupConfig]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadStartupConfig {
    self.startupSwitch.on = [[XXLocalDataService sharedInstance] startUpConfigSwitch];
    NSString *selectedBootScript = [[XXLocalDataService sharedInstance] startUpConfigScriptPath];
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
}

@end
