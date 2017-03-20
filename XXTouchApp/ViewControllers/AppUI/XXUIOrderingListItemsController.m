//
//  XXUIOrderingListItemsController.m
//  XXTouchApp
//
//  Created by Zheng on 19/03/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXUIOrderingListItemsController.h"

#define kXXUICellIdentifier @"XXUICellIdentifier"

@interface XXUIOrderingListItemsController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation XXUIOrderingListItemsController {
    NSMutableArray *_currentValues;
    NSMutableArray *_leftValues;
    NSUInteger _maxCount;
    NSUInteger _minCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.specifier.properties[@"maxCount"]) {
        _maxCount = [self.specifier.properties[@"maxCount"] unsignedIntegerValue];
    } else {
        _maxCount = 1;
    }
    
    if (self.specifier.properties[@"minCount"]) {
        _minCount = [self.specifier.properties[@"minCount"] unsignedIntegerValue];
    } else {
        _minCount = 0;
    }
    
    _currentValues = [[self readPreferenceValue:self.specifier] mutableCopy];
    if (_currentValues == nil) {
        _currentValues = [NSMutableArray array];
    }
    NSMutableArray *leftValues = [NSMutableArray arrayWithArray:self.specifier.titleDictionary.allKeys];
    for (id curVal in _currentValues) {
        [leftValues removeObject:curVal];
    }
    _leftValues = leftValues;
    
    if ([_currentValues isKindOfClass:[NSArray class]]) {
        [[NSBundle mainBundle] loadNibNamed:@"XXTableViewPlain" owner:self options:nil];
        self.tableView.frame = self.view.bounds;
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tableView.editing = YES;
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

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (sourceIndexPath.section == 1 && proposedDestinationIndexPath.section == 0) {
        // Move In
        if (_currentValues.count >= _maxCount) {
            return sourceIndexPath;
        }
    } else if (sourceIndexPath.section == 0 && proposedDestinationIndexPath.section == 1) {
        // Move Out
        if (_currentValues.count <= _minCount) {
            return sourceIndexPath;
        }
    }
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section == 0 && destinationIndexPath.section == 0) {
        [_currentValues exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    } else if (sourceIndexPath.section == 1 && destinationIndexPath.section == 1) {
        [_leftValues exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    } else if (sourceIndexPath.section == 0 && destinationIndexPath.section == 1) {
        [_leftValues insertObject:_currentValues[sourceIndexPath.row] atIndex:destinationIndexPath.row];
        [_currentValues removeObjectAtIndex:sourceIndexPath.row];
    } else if (sourceIndexPath.section == 1 && destinationIndexPath.section == 0) {
        [_currentValues insertObject:_leftValues[sourceIndexPath.row] atIndex:destinationIndexPath.row];
        [_leftValues removeObjectAtIndex:sourceIndexPath.row];
    }
    [self setPreferenceValue:[_currentValues copy] specifier:self.specifier];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Selected", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Remained", nil);
    }
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"";
    } else if (section == 1) {
        return self.specifier.properties[@"staticTextMessage"];
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _currentValues.count;
    } else if (section == 1) {
        return _leftValues.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:kXXUICellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kXXUICellIdentifier];
        cell.tintColor = STYLE_TINT_COLOR;
        cell.showsReorderControl = YES;
        if (indexPath.section == 0) {
            cell.textLabel.text = self.specifier.titleDictionary[_currentValues[indexPath.row]];
        } else if (indexPath.section == 1) {
            cell.textLabel.text = self.specifier.titleDictionary[_leftValues[indexPath.row]];
        }
        
    }
    return cell;
}

@end

