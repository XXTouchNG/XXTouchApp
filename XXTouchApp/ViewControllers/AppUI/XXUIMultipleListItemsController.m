//
//  XXUIMultipleListItemsController.m
//  XXTouchApp
//
//  Created by Zheng on 19/03/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXUIMultipleListItemsController.h"

#define kXXUICellIdentifier @"XXUICellIdentifier"

@interface XXUIMultipleListItemsController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation XXUIMultipleListItemsController {
    NSMutableArray *_currentValues;
    NSUInteger _maxCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.specifier.properties[@"maxCount"]) {
        _maxCount = [self.specifier.properties[@"maxCount"] unsignedIntegerValue];
    } else {
        _maxCount = 1;
    }
    
    _currentValues = [[self readPreferenceValue:self.specifier] mutableCopy];
    if (_currentValues == nil) {
        _currentValues = [NSMutableArray array];
    }
    
    if ([_currentValues isKindOfClass:[NSArray class]]) {
        [[NSBundle mainBundle] loadNibNamed:@"XXTableViewGrouped" owner:self options:nil];
        self.tableView.frame = self.view.bounds;
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.view addSubview:self.tableView];
    }
}

#pragma mark - Data sources

- (NSString *)title {
    return self.specifier.properties[@"label"];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return self.specifier.properties[@"staticTextMessage"];
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.specifier.titleDictionary.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
    {
        UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:kXXUICellIdentifier];
        if (nil == cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:kXXUICellIdentifier];
            cell.tintColor = STYLE_TINT_COLOR;
            id curKey = self.specifier.titleDictionary.allKeys[indexPath.row];
            cell.textLabel.text = self.specifier.titleDictionary[curKey];
            for (id value in _currentValues) {
                if ([curKey isEqual:value]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
        }
        return cell;
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        id curKey = self.specifier.titleDictionary.allKeys[indexPath.row];
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            // mark
            if (_currentValues.count < _maxCount) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [_currentValues addObject:curKey];
                [self setPreferenceValue:[_currentValues copy] specifier:self.specifier];
            } else {
                [self.navigationController.view makeToast:[NSString stringWithFormat:NSLocalizedString(@"You can select no more than %ld row(s).", nil), _maxCount]];
            }
        } else {
            // unmark
            cell.accessoryType = UITableViewCellAccessoryNone;
            [_currentValues removeObject:curKey];
            [self setPreferenceValue:[_currentValues copy] specifier:self.specifier];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
