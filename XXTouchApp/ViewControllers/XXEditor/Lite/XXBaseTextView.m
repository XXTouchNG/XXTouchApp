//
//  XXBaseTextView.m
//  XXTouchApp
//
//  Created by Zheng on 9/19/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXBaseTextView.h"
#import <CoreText/CoreText.h>

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]

@implementation XXBaseTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonSetup];
    }
    
    return self;
}

- (void)commonSetup
{
    _defaultFont = [UIFont fontWithName:@"CourierNewPSMT" size:14.f];
    _boldFont = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:14.f];
    _italicFont = [UIFont fontWithName:@"CourierNewPS-ItalicMT" size:14.f];
    
    self.font = _defaultFont;
    self.textColor = [UIColor colorWithWhite:.25f alpha:1.f];
    
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(defaultFont)) options:NSKeyValueObservingOptionNew context:0];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(boldFont)) options:NSKeyValueObservingOptionNew context:0];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(italicFont)) options:NSKeyValueObservingOptionNew context:0];
}

- (void)setHighlightLuaSymbols:(BOOL)highlightLuaSymbols {
    _highlightLuaSymbols = highlightLuaSymbols;
    if (highlightLuaSymbols) {
        self.tokens = [self solverTokens];
    } else {
        self.tokens = nil;
    }
}

- (NSArray *)solverTokens
{
    NSArray *solverTokens = @[
            [CYRToken tokenWithName:@"operator"
                         expression:@"[/\\*,\\;:~=<>\\+\\-\\^!\\#%&\\||(\\.\\.)]"
                         attributes:@{
                                      NSForegroundColorAttributeName : RGB(245, 0, 110)
                                      }],
            [CYRToken tokenWithName:@"number"
                         expression:@"\\b(0[xX][0-9a-fA-F]+|\\d+(?:\\.\\d+)?(?:[eE][+-]?\\d+)?|\\.\\d+(?:[eE][+-]?\\d+)?)"
                         attributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithHexString:@"A8017E"]
                                      }],
            [CYRToken tokenWithName:@"round_brackets"
                         expression:@"[\\(\\)\\[\\]\\{\\}]"
                         attributes:@{
                                      NSForegroundColorAttributeName : RGB(161, 75, 0)
                                      }],
            [CYRToken tokenWithName:@"constants"
                         expression:@"\\b(false|true|nil|_G|_VERSION)\\b"
                         attributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithHexString:@"A535AE"]
                                      }],
            [CYRToken tokenWithName:@"reserved_words"
                         expression:@"\\b(and|break|do|else|elseif|end|for|function|goto|if|in|local|not|or|repeat|return|then|until|while)\\b"
                         attributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithHexString:@"006699"],
                                      NSFontAttributeName : self.boldFont
                                      }],
            [CYRToken tokenWithName:@"string_multi"
                         expression:@"\\[\\[.*?(\\]\\]|$)"
                         attributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithHexString:@"ED7722"],
                                      NSFontAttributeName : self.defaultFont
                                      }],
            [CYRToken tokenWithName:@"string_single"
                         expression:@"([\"'])(?:[^\1\\\\]|\\\\[\\d\\D])*?(\\1|\\n|$)"
                         attributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithHexString:@"ED7722"],
                                      NSFontAttributeName : self.defaultFont
                                      }],
            [CYRToken tokenWithName:@"comment_single"
                         expression:@"--[^\\n]*"
                         attributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithHexString:@"AF82D4"],
                                      NSFontAttributeName : self.italicFont
                                      }],
            [CYRToken tokenWithName:@"comment_multi"
                         expression:@"--\\[\\[.*?\\]\\]"
                         attributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithHexString:@"AF82D4"],
                                      NSFontAttributeName : self.italicFont
                                      }]
            ];
    return solverTokens;
}


#pragma mark - Cleanup

- (void)dealloc
{
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(defaultFont))];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(boldFont))];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(italicFont))];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(defaultFont))] ||
        [keyPath isEqualToString:NSStringFromSelector(@selector(boldFont))] ||
        [keyPath isEqualToString:NSStringFromSelector(@selector(italicFont))])
    {
        // Reset the tokens, this will clear any existing formatting
        self.tokens = [self solverTokens];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - Overrides

- (void)setDefaultFont:(UIFont *)defaultFont
{
    _defaultFont = defaultFont;
    self.font = defaultFont;
}

@end
