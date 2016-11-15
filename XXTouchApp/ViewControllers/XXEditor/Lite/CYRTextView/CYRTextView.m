//
//  CYRTextView.m
//
//  Version 0.4.0
//
//  Created by Illya Busigin on 01/05/2014.
//  Copyright (c) 2014 Cyrillian, Inc.
//  Copyright (c) 2013 Dominik Hauser
//  Copyright (c) 2013 Sam Rijs
//
//  Distributed under MIT license.
//  Get the latest version from here:
//
//  https://github.com/illyabusigin/CYRTextView
//
// The MIT License (MIT)
//
// Copyright (c) 2014 Cyrillian, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "CYRTextView.h"
#import "CYRLayoutManager.h"

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]

static void *CYRTextViewContext = &CYRTextViewContext;
static const float kCursorVelocity = 1.0f/8.0f;

@interface CYRTextView ()

@property (nonatomic, strong) NSLayoutManager *lineNumberLayoutManager;
@property (nonatomic, strong) CYRTextStorage *syntaxTextStorage;
@property (nonatomic, assign) BOOL lineNumbersEnabled;
@property (nonatomic, assign) NSRange startRange;

@end

@implementation CYRTextView

#pragma mark - Initialization & Setup

- (id)initWithFrame:(CGRect)frame lineNumbersEnabled:(BOOL)lineNumbersEnabled
{
    _lineNumbersEnabled = lineNumbersEnabled;
    
    CYRTextStorage *textStorage = [CYRTextStorage new];
    NSLayoutManager *layoutManager = lineNumbersEnabled ? [CYRLayoutManager new] : [NSLayoutManager new];
    self.lineNumberLayoutManager = layoutManager;
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    
    textContainer.widthTracksTextView = YES;
    [layoutManager addTextContainer:textContainer];

    [textStorage removeLayoutManager:textStorage.layoutManagers.firstObject];
    [textStorage addLayoutManager:layoutManager];
    
    self.syntaxTextStorage = textStorage;
    
    if ((self = [super initWithFrame:frame textContainer:textContainer]))
    {
        self.contentMode = UIViewContentModeRedraw;
        
        [self _commonSetup];
    }
    
    return self;
}

- (void)_commonSetup
{
    // Setup observers
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(font)) options:0 context:CYRTextViewContext];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(textColor)) options:0 context:CYRTextViewContext];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(selectedTextRange)) options:0 context:CYRTextViewContext];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(selectedRange)) options:0 context:CYRTextViewContext];
    
    // Setup defaults
    self.font = [UIFont systemFontOfSize:14.0f];
    self.textColor = [UIColor blackColor];
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.autocorrectionType     = UITextAutocorrectionTypeNo;
    self.gutterBackgroundColor = [UIColor colorWithWhite:.97f alpha:1.f];
    self.gutterLineColor       = [UIColor lightGrayColor];
    
    // Inset the content to make room for line numbers
    self.textContainerInset = self.lineNumbersEnabled ?
    UIEdgeInsetsMake(8, ((CYRLayoutManager *)self.lineNumberLayoutManager).gutterWidth, 8, 0) :
    UIEdgeInsetsMake(8, 8, 8, 8);
    
    // Setup the gesture recognizers
    _singleFingerPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(singleFingerPanHappend:)];
    _singleFingerPanRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:_singleFingerPanRecognizer];
    
    _doubleFingerPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doubleFingerPanHappend:)];
    _doubleFingerPanRecognizer.minimumNumberOfTouches = 2;
    [self addGestureRecognizer:_doubleFingerPanRecognizer];
}

#pragma mark - Cleanup

- (void)dealloc
{
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(font))];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(textColor))];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(selectedTextRange))];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(selectedRange))];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(font))] && context == CYRTextViewContext)
    {
        // Whenever the UITextView font is changed we want to keep a reference in the stickyFont ivar. We do this to counteract a bug where the underlying font can be changed without notice and cause undesired behaviour.
        self.syntaxTextStorage.defaultFont = self.font;
    }
    else if ([keyPath isEqualToString:NSStringFromSelector(@selector(textColor))] && context == CYRTextViewContext)
    {
        self.syntaxTextStorage.defaultTextColor = self.textColor;
    }
    else if (([keyPath isEqualToString:NSStringFromSelector(@selector(selectedTextRange))] ||
              [keyPath isEqualToString:NSStringFromSelector(@selector(selectedRange))]) && context == CYRTextViewContext)
    {
        [self setNeedsDisplay];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Overrides

- (BOOL)syntaxHighlight {
    return self.syntaxTextStorage.syntaxHighlight;
}

- (void)setSyntaxHighlight:(BOOL)syntaxHighlight {
    self.syntaxTextStorage.syntaxHighlight = syntaxHighlight;
}

- (void)setTokens:(NSMutableArray *)tokens
{
    [self.syntaxTextStorage setTokens:tokens];
}

- (void)setTokens:(NSMutableArray *)tokens shouldUpdate:(BOOL)update
{
    [self.syntaxTextStorage setTokens:tokens shouldUpdate:update];
}

- (NSArray *)tokens
{
    CYRTextStorage *syntaxTextStorage = (CYRTextStorage *)self.textStorage;
    return syntaxTextStorage.tokens;
}

- (void)setText:(NSString *)text
{
    UITextRange *textRange = [self textRangeFromPosition:self.beginningOfDocument toPosition:self.endOfDocument];
    [self replaceRange:textRange withText:text];
}

- (void)setDefaultFont:(UIFont *)defaultFont shouldUpdate:(BOOL)update {
    _defaultFont = defaultFont;
    self.syntaxTextStorage.defaultFont = defaultFont;
    if (update)
    {
        self.font = defaultFont; // Adjust content size
    }
}

#pragma mark - Line Drawing

- (void)drawRect:(CGRect)rect
{
    if (!self.lineNumbersEnabled) {
        [super drawRect:rect];
        return;
    }
    
    CYRLayoutManager *manager = (CYRLayoutManager *)self.lineNumberLayoutManager;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = self.bounds;
    
    CGFloat height = MAX(CGRectGetHeight(bounds), self.contentSize.height) + 200;
    
    CGContextSetFillColorWithColor(context, self.gutterBackgroundColor.CGColor);
    CGContextFillRect(context, CGRectMake(bounds.origin.x, bounds.origin.y, manager.gutterWidth, height));
    
    CGContextSetFillColorWithColor(context, self.gutterLineColor.CGColor);
    CGContextFillRect(context, CGRectMake(manager.gutterWidth, bounds.origin.y, 0.5, height));
    
    [super drawRect:rect];
}


#pragma mark - Gestures

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _singleFingerPanRecognizer || gestureRecognizer == _doubleFingerPanRecognizer)
    {
        CGPoint translation = [gestureRecognizer translationInView:self];
        return fabs(translation.x) > fabs(translation.y);
    }
    
    return YES;
    
}

- (void)singleFingerPanHappend:(UIPanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        _startRange = self.selectedRange;
    }
    
    CGFloat cursorLocation = MAX(_startRange.location + [sender translationInView:self].x * kCursorVelocity, 0);
    
    self.selectedRange = NSMakeRange(cursorLocation, 0);
}

- (void)doubleFingerPanHappend:(UIPanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        _startRange = self.selectedRange;
    }
    
    CGFloat cursorLocation = MAX(_startRange.location + [sender translationInView:self].x * kCursorVelocity, 0);
    
    if (cursorLocation > _startRange.location)
    {
        self.selectedRange = NSMakeRange(_startRange.location, fabs(_startRange.location - cursorLocation));
    }
    else
    {
        self.selectedRange = NSMakeRange(cursorLocation, fabs(_startRange.location - cursorLocation + 1));
    }
}

@end
