//
//  XXTerminalTextView.m
//  XXTouchApp
//
//  Created by Zheng on 10/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXTerminalTextView.h"
#import "XXLocalDataService.h"

@interface XXTerminalTextView ()

@property (nonatomic, strong) NSDictionary *defaultAttributes;
@property (nonatomic, strong) NSDictionary *messageAttributes;
@property (nonatomic, strong) NSDictionary *errorAttributes;

@property (nonatomic, strong) NSDictionary *inputAttributes;

@property (nonatomic, assign) NSUInteger lockedLocation;

@end

@implementation XXTerminalTextView

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // Appearance
    self.backgroundColor = [UIColor colorWithRGB:0xfefefe];
    self.tintColor = STYLE_TINT_COLOR;
    self.typingAttributes = self.defaultAttributes;
    
    // Property
    self.alwaysBounceVertical = YES;
    self.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
}

#pragma mark - Getters

- (NSDictionary *)defaultAttributes {
    if (!_defaultAttributes) {
        _defaultAttributes = @{
                               NSFontAttributeName: [[XXLocalDataService sharedInstance] fontFamilyArray][0],
                               NSForegroundColorAttributeName: [UIColor colorWithWhite:.33f alpha:1.f],
                               };
    }
    return _defaultAttributes;
}

- (NSDictionary *)messageAttributes {
    if (!_messageAttributes) {
        _messageAttributes = @{
                             NSFontAttributeName: [[XXLocalDataService sharedInstance] fontFamilyArray][1],
                             NSForegroundColorAttributeName: [UIColor colorWithWhite:.33f alpha:1.f],
                             };
    }
    return _messageAttributes;
}

- (NSDictionary *)errorAttributes {
    if (!_errorAttributes) {
        _errorAttributes = @{
                               NSFontAttributeName: [[XXLocalDataService sharedInstance] fontFamilyArray][0],
                               NSForegroundColorAttributeName: [UIColor redColor],
                               };
    }
    return _errorAttributes;
}

- (NSDictionary *)inputAttributes {
    if (!_inputAttributes) {
        _inputAttributes = @{
                             NSFontAttributeName: [[XXLocalDataService sharedInstance] fontFamilyArray][0],
                             NSForegroundColorAttributeName: STYLE_TINT_COLOR,
                             };
    }
    return _inputAttributes;
}

#pragma mark - Terminal

- (void)resetTypingAttributes {
    [self setTypingAttributes:self.inputAttributes];
}

- (BOOL)canDeleteBackward {
    return ((self.text.length - 1) > self.lockedLocation);
}

- (void)lockLocation {
    [self setLockedLocation:(self.text.length - 1)];
}

- (void)appendString:(NSString *)text withAttributes:(NSDictionary *)attrs {
    [self.textStorage beginEditing];
//    [self insertText:[NSString stringWithFormat:@"%@", text]];
    NSMutableAttributedString *mutableAttrString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    NSAttributedString *appendAttrString = [[NSAttributedString alloc] initWithString:text attributes:attrs];
    [mutableAttrString appendAttributedString:appendAttrString];
    [self.textStorage setAttributedString:mutableAttrString];
    [self.textStorage endEditing];
    [self lockLocation];
    [self resetTypingAttributes];
}

- (void)appendString:(NSString *)text {
    [self appendString:text withAttributes:self.defaultAttributes];
}

- (void)appendMessage:(NSString *)text {
    [self appendString:text withAttributes:self.messageAttributes];
}

- (void)appendError:(NSString *)text {
    [self appendString:text withAttributes:self.errorAttributes];
}

- (NSString *)getBufferString {
    if (self.text.length > self.lockedLocation) {
        NSString *bufferedString = [self.text substringFromIndex:self.lockedLocation + 1];
        return bufferedString;
    }
    return @"";
}

- (void)dealloc {
    CYLog(@"");
}

@end
