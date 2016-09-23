//
//  XXToolbar.m
//  XXTouchApp
//
//  Created by Zheng on 8/31/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXToolbar.h"

@implementation XXToolbar

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Top Toolbar

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(ctx, 0.85, 0.85, 0.85, 1.0);
    CGContextSetLineWidth(ctx, 1.0f);
    CGPoint aPoint[2] = {
        CGPointMake(0.0, self.frame.size.height),
        CGPointMake(self.frame.size.width, self.frame.size.height)
    };
    CGContextAddLines(ctx, aPoint, 2);
    CGContextStrokePath(ctx);
}

- (NSArray <UIBarButtonItem *> *)defaultToolbarButtons {
    if (!_defaultToolbarButtons) {
        _defaultToolbarButtons = @[self.scanButton, self.flexibleSpace, self.addItemButton, self.flexibleSpace, self.sortByButton, self.flexibleSpace, self.pasteButton];
    }
    return _defaultToolbarButtons;
}

- (NSArray <UIBarButtonItem *> *)editingToolbarButtons {
    if (!_editingToolbarButtons) {
        _editingToolbarButtons = @[self.shareButton, self.flexibleSpace, self.compressButton, self.flexibleSpace, self.trashButton, self.flexibleSpace, self.pasteButton];
    }
    return _editingToolbarButtons;
}

- (NSArray <UIBarButtonItem *> *)selectingBootscriptButtons {
    if (!_selectingBootscriptButtons) {
        _selectingBootscriptButtons = @[self.flexibleSpace, self.sortByButton, self.flexibleSpace];
    }
    return _selectingBootscriptButtons;
}

- (UIBarButtonItem *)flexibleSpace {
    if (!_flexibleSpace) {
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        _flexibleSpace = flexibleSpace;
    }
    return _flexibleSpace;
}

- (UIBarButtonItem *)scanButton {
    if (!_scanButton) {
        UIBarButtonItem *scanButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list-scan"]
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self.tapDelegate
                                                                      action:@selector(toolbarButtonTapped:)];
        scanButton.enabled = YES;
        _scanButton = scanButton;
    }
    return _scanButton;
}

- (UIBarButtonItem *)compressButton {
    if (!_compressButton) {
        UIBarButtonItem *compressButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list-compress"]
                                                                           style:UIBarButtonItemStyleBordered
                                                                          target:self.tapDelegate
                                                                          action:@selector(toolbarButtonTapped:)];
        compressButton.enabled = NO;
        _compressButton = compressButton;
    }
    return _compressButton;
}

- (UIBarButtonItem *)addItemButton {
    if (!_addItemButton) {
        UIBarButtonItem *addItemButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list-add"]
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self.tapDelegate
                                                                         action:@selector(toolbarButtonTapped:)];
        addItemButton.enabled = YES;
        _addItemButton = addItemButton;
    }
    return _addItemButton;
}

- (UIBarButtonItem *)sortByButton {
    if (!_sortByButton) {
        UIBarButtonItem *sortByButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sort-alpha"]
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self.tapDelegate
                                                                        action:@selector(toolbarButtonTapped:)];
        sortByButton.enabled = YES;
        _sortByButton = sortByButton;
    }
    return _sortByButton;
}

- (UIBarButtonItem *)shareButton {
    if (!_shareButton) {
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list-share"]
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self.tapDelegate
                                                                       action:@selector(toolbarButtonTapped:)];
        shareButton.enabled = NO;
        _shareButton = shareButton;
    }
    return _shareButton;
}

- (UIBarButtonItem *)pasteButton {
    if (!_pasteButton) {
        UIBarButtonItem *pasteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list-paste"]
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self.tapDelegate
                                                                       action:@selector(toolbarButtonTapped:)];
        pasteButton.enabled = NO;
        _pasteButton = pasteButton;
    }
    return _pasteButton;
}

- (UIBarButtonItem *)trashButton {
    if (!_trashButton) {
        UIBarButtonItem *trashButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list-trash"]
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self.tapDelegate
                                                                       action:@selector(toolbarButtonTapped:)];
        trashButton.enabled = NO;
        _trashButton = trashButton;
    }
    return _trashButton;
}

@end
