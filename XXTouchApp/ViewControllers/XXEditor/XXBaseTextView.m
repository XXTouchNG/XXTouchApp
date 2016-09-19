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
    _defaultFont = [UIFont fontWithName:@"Courier New" size:14.f];
    _boldFont = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:14.f];
    _italicFont = [UIFont fontWithName:@"CourierNewPS-ItalicMT" size:14.f];
    
    self.font = _defaultFont;
    self.textColor = [UIColor blackColor];
    
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
                                      NSForegroundColorAttributeName : RGB(0, 0, 255)
                                      }],
            [CYRToken tokenWithName:@"round_brackets"
                         expression:@"[\\(\\)]"
                         attributes:@{
                                      NSForegroundColorAttributeName : RGB(161, 75, 0)
                                      }],
            [CYRToken tokenWithName:@"square_brackets"
                         expression:@"[\\[\\]\\{\\}]"
                         attributes:@{
                                      NSForegroundColorAttributeName : RGB(105, 0, 0)
                                      }],
            [CYRToken tokenWithName:@"constants"
                         expression:@"\\b(false|true|nil)\\b"
                         attributes:@{
                                      NSForegroundColorAttributeName : RGB(250, 128, 10)
                                      }],
            [CYRToken tokenWithName:@"reserved_words"
                         expression:@"\\b(and|break|do|else|elseif|end|for|function|goto|if|in|local|not|or|repeat|return|then|until|while)\\b"
                         attributes:@{
                                      NSForegroundColorAttributeName : RGB(104, 0, 111),
                                      NSFontAttributeName : self.boldFont
                                      }],
            [CYRToken tokenWithName:@"string_multi"
                         expression:@"\\[\\[.*?(\\]\\]|$)"
                         attributes:@{
                                      NSForegroundColorAttributeName : RGB(24, 110, 109),
                                      NSFontAttributeName : self.defaultFont
                                      }],
            [CYRToken tokenWithName:@"string_single"
                         expression:@"([\"'])(?:[^\1\\\\]|\\\\[\\d\\D])*?(\\1|$)"
                         attributes:@{
                                      NSForegroundColorAttributeName : RGB(24, 110, 109),
                                      NSFontAttributeName : self.defaultFont
                                      }],
            [CYRToken tokenWithName:@"comment_single"
                         expression:@"--[^\\n]*"
                         attributes:@{
                                      NSForegroundColorAttributeName : RGB(31, 131, 0),
                                      NSFontAttributeName : self.italicFont
                                      }],
            [CYRToken tokenWithName:@"comment_multi"
                         expression:@"--\\[\\[.*?\\]\\]"
                         attributes:@{
                                      NSForegroundColorAttributeName : RGB(31, 131, 0),
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
