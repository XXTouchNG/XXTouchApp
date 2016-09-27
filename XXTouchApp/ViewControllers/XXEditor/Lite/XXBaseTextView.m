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
            [CYRToken tokenWithName:@"keyword.operator.lua"
                         expression:@"\\+|-|%|#|\\*|\\/|\\^|==?|~=|<=?|>=?|(?<!\\.)\\.{2}(?!\\.)"
                         attributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithRGB:0x687687],
                                      NSFontAttributeName : self.defaultFont
                                      }],
            [CYRToken tokenWithName:@"keyword.brackets.lua"
                         expression:@"[\\(\\)\\[\\]\\{\\}]"
                         attributes:@{
                                      NSForegroundColorAttributeName : RGB(161, 75, 0),
                                      NSFontAttributeName : self.defaultFont
                                      }],
            [CYRToken tokenWithName:@"constant.numeric.lua"
                         expression:@"\\b(0[xX][0-9a-fA-F]+|\\d+(?:\\.\\d+)?(?:[eE][+-]?\\d+)?|\\.\\d+(?:[eE][+-]?\\d+)?)"
                         attributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithRGB:0xA8017E],
                                      NSFontAttributeName : self.defaultFont
                                      }],
            [CYRToken tokenWithName:@"variable.language.self.lua"
                         expression:@"(?<![^.]\\.|:)\\b(self)\\b"
                         attributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithRGB:0x318495],
                                      NSFontAttributeName : self.defaultFont
                                      }],
            [CYRToken tokenWithName:@"constant.language.lua"
                         expression:@"(?<![^.]\\.|:)\\b(false|nil|true|_G|_VERSION|math\\.(pi|huge))\\b|(?<![.])\\.{3}(?!\\.)"
                         attributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithRGB:0x585CF6],
                                      NSFontAttributeName : self.defaultFont
                                      }],
            [CYRToken tokenWithName:@"keyword.operator.word.lua"
                         expression:@"\\b(and|or|not)\\b"
                         attributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithRGB:0x687687],
                                      NSFontAttributeName : self.defaultFont
                                      }],
            [CYRToken tokenWithName:@"keyword.control.lua"
                         expression:@"\\b(break|do|else|for|if|elseif|return|then|repeat|while|until|end|function|local|in)\\b"
                         attributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithRGB:0x0C450D],
                                      NSFontAttributeName : self.boldFont
                                      }],
            [CYRToken tokenWithName:@"support.function.library.lua"
                         expression:@"(?<![^.]\\.|:)\\b(coroutine\\.(create|resume|running|status|wrap|yield)|string\\.(byte|char|dump|find|format|gmatch|gsub|len|lower|match|rep|reverse|sub|upper)|table\\.(concat|insert|maxn|remove|sort)|math\\.(abs|acos|asin|atan2?|ceil|cosh?|deg|exp|floor|fmod|frexp|ldexp|log|log10|max|min|modf|pow|rad|random|randomseed|sinh?|sqrt|tanh?)|io\\.(close|flush|input|lines|open|output|popen|read|tmpfile|type|write)|os\\.(clock|date|difftime|execute|exit|getenv|remove|rename|setlocale|time|tmpname)|package\\.(cpath|loaded|loadlib|path|preload|seeall)|debug\\.(debug|[gs]etfenv|[gs]ethook|getinfo|[gs]etlocal|[gs]etmetatable|getregistry|[gs]etupvalue|traceback))\\b(?=[( {])"
                         attributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithRGB:0x3C4C72],
                                      NSFontAttributeName : self.defaultFont
                                      }],
            [CYRToken tokenWithName:@"support.function.lua"
                         expression:@"(?<![^.]\\.|:)\\b(assert|collectgarbage|dofile|error|getfenv|getmetatable|ipairs|loadfile|loadstring|module|next|pairs|pcall|print|rawequal|rawget|rawset|require|select|setfenv|setmetatable|tonumber|tostring|type|unpack|xpcall)\\b(?=[( {])"
                         attributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithRGB:0x3C4C72],
                                      NSFontAttributeName : self.defaultFont
                                      }],
            [CYRToken tokenWithName:@"comment.line.double-dash.lua"
                         expression:@"--(?!\\[\\[)[^\\n]*"
                         attributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithRGB:0x0066FF],
                                      NSFontAttributeName : self.italicFont
                                      }],
            [CYRToken tokenWithName:@"comment.block.lua"
                         expression:@"--\\[(=*)\\[.*?\\]\\1\\]"
                         attributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithRGB:0x0066FF],
                                      NSFontAttributeName : self.italicFont
                                      }],
            [CYRToken tokenWithName:@"string.quoted.double.lua"
                         expression:@"([\"'])(?:[^\\\\]|\\\\[\\d\\D])*?(\\1|\\n|$)"
                         attributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithRGB:0x036A07],
                                      NSFontAttributeName : self.defaultFont
                                      }],
            [CYRToken tokenWithName:@"string.quoted.other.multiline.lua"
                         expression:@"(?<!--)\\[(=*)\\[.*?(\\]\\1\\]|$)"
                         attributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithRGB:0x036A07],
                                      NSFontAttributeName : self.defaultFont
                                      }],
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
