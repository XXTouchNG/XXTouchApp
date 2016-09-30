//
//  XXLocationPicker.m
//  XXTouchApp
//
//  Created by Zheng on 9/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXLocationPicker.h"
#import "XXCodeMakerService.h"
#import "MBPlacePickerController.h"

@interface XXLocationPicker () <MBPlacePickerDelegate>
@property (nonatomic, strong) MBPlacePickerController *locationPickerController;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@end

@implementation XXLocationPicker

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (MBPlacePickerController *)locationPickerController {
    if (!_locationPickerController) {
        MBPlacePickerController *locationPickerController = [[MBPlacePickerController alloc] init];
        locationPickerController.delegate = self;
        locationPickerController.sortByContinent = YES;
        locationPickerController.showSearch = YES;
        locationPickerController.map.showUserLocation = YES;
        locationPickerController.map.markerDiameter = 15.f;
        
        _locationPickerController = locationPickerController;
    }
    return _locationPickerController;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 2) {
        self.latitudeLabel.text = @"N/A";
        self.longitudeLabel.text = @"N/A";
        [self.navigationController.view makeToast:NSLocalizedString(@"Operation completed", nil)];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [self.navigationController pushViewController:self.locationPickerController animated:YES];
    }
}

- (IBAction)next:(UIBarButtonItem *)sender {
    if (_codeBlock) {
        XXCodeBlockModel *newBlock = [_codeBlock mutableCopy];
        NSString *code = newBlock.code;
        NSRange range = [code rangeOfString:@"@loc@"];
        if (range.length == 0) return;
        if (
            [self.latitudeLabel.text isEqualToString:@"N/A"] ||
            [self.longitudeLabel.text isEqualToString:@"N/A"]
            ) {
            newBlock.code = [code stringByReplacingCharactersInRange:range withString:@", "];
        } else {
            newBlock.code = [code stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"%@, %@", self.latitudeLabel.text, self.longitudeLabel.text]];
        }
        newBlock.offset = -1;
        [XXCodeMakerService pushToMakerWithCodeBlockModel:newBlock controller:self];
    }
}

#pragma mark - MBPlacePickerControllerDelegate

- (void)placePickerController:(MBPlacePickerController *)placePicker didChangeToPlace:(CLLocation *)place
{
    CGFloat lat = place.coordinate.latitude;
    CGFloat lon = place.coordinate.longitude;
    
    self.latitudeLabel.text = [NSString stringWithFormat:@"%f", lat];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%f", lon];
}

@end
