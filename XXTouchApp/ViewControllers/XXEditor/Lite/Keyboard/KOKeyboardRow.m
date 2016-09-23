//
//  ExtraKeyboardRow.m
//  KeyboardTest
//
//  Created by Kuba on 28.06.12.
//  Copyright (c) 2012 Adam Horacek, Kuba Brecka
//
//  Website: http://www.becomekodiak.com/
//  github: http://github.com/adamhoracek/KOKeyboard
//	Twitter: http://twitter.com/becomekodiak
//  Mail: adam@becomekodiak.com, kuba@becomekodiak.com
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "KOKeyboardRow.h"
#import "KOSwipeButton.h"

@interface KOKeyboardRow ()

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, assign) CGRect startLocation;

@end

@implementation KOKeyboardRow

@synthesize textView, startLocation;

+ (KOKeyboardRow *)applyToTextView:(UITextView *)t {
    NSUInteger buttonCount = 11;
    CGFloat barWidth = t.width;
    CGFloat barHeight = 72.f;
    CGFloat buttonHeight = 60.f;
    CGFloat leftMargin = 7.f;
    CGFloat topMargin = 1.f;
    CGFloat buttonSpacing = 13.f;
    CGFloat buttonWidth = 57.f;
    
    NSString *keys = nil;
    if (![[UIDevice currentDevice] isPad]) {
        buttonCount = 9;
        buttonSpacing = 4.f;
        topMargin = 0.f;
        leftMargin = 6.f;
        buttonWidth = (barWidth - (buttonSpacing * (buttonCount - 1)) - (leftMargin * 2)) / buttonCount;
        buttonHeight = buttonWidth;
        barHeight = buttonHeight + buttonSpacing * 2;
        
        keys = @"TTTTT()\"[]{}'<>\\/$´`◉◉◉◉◉~^|€£-+=%*!?#@&_:;,.";
    } else {
        keys = @"TTTTT()\"[]{}'<>\\/$´`~^|€£◉◉◉◉◉-+=%*!?#@&_:;,.1203467589";
    }
    
    KOKeyboardRow *v = [[KOKeyboardRow alloc] initWithFrame:CGRectMake(0, 0, barWidth, barHeight) inputViewStyle:UIInputViewStyleKeyboard];
    [v setBackgroundColor:[UIColor clearColor]];
    v.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    v.textView = t;
    leftMargin = (barWidth - buttonWidth * buttonCount - buttonSpacing * (buttonCount - 1)) / 2;
    for (int i = 0; i < buttonCount; i++) {
        KOSwipeButton *b = [[KOSwipeButton alloc] initWithFrame:CGRectMake(leftMargin + i * (buttonSpacing + buttonWidth), topMargin + (barHeight - buttonHeight) / 2, buttonWidth, buttonHeight)];
        b.keys = [keys substringWithRange:NSMakeRange(i * 5, 5)];
        b.delegate = v;
        b.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [v addSubview:b];
    }
    t.inputAccessoryView = v;

    return v;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1.0);
    CGContextSetLineWidth(ctx, 1.5);
    CGPoint aPoints[2];
    aPoints[0] = CGPointMake(0, 0);
    aPoints[1] = CGPointMake(self.frame.size.width, 0);
    CGContextAddLines(ctx, aPoints, 2);
    CGPoint bPoints[2];
    bPoints[0] = CGPointMake(0, self.frame.size.height);
    bPoints[1] = CGPointMake(self.frame.size.width, self.frame.size.height);
    CGContextAddLines(ctx, bPoints, 2);
    CGContextDrawPath(ctx, kCGPathStroke);
}

- (void)insertText:(NSString *)text {
    [textView insertText:text];
}

- (void)trackPointStarted {
    startLocation = [textView caretRectForPosition:textView.selectedTextRange.start];
}

- (void)trackPointMovedX:(int)xdiff Y:(int)ydiff selecting:(BOOL)selecting {
    CGRect loc = startLocation;

    loc.origin.y += textView.font.lineHeight;

    UITextPosition *p1 = [textView closestPositionToPoint:loc.origin];

    loc.origin.x -= xdiff;
    loc.origin.y -= ydiff;

    UITextPosition *p2 = [textView closestPositionToPoint:loc.origin];

    if (!selecting) {
        p1 = p2;
    }
    UITextRange *r = [textView textRangeFromPosition:p1 toPosition:p2];

    textView.selectedTextRange = r;
}

- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

- (void)selectionComplete {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UITextRange *selectionRange = [textView selectedTextRange];
    CGRect selectionStartRect = [textView caretRectForPosition:selectionRange.start];
    CGRect selectionEndRect = [textView caretRectForPosition:selectionRange.end];
    CGPoint selectionCenterPoint = (CGPoint) {(selectionStartRect.origin.x + selectionEndRect.origin.x) / 2, (selectionStartRect.origin.y + selectionStartRect.size.height / 2)};
    [menuController setTargetRect:[textView caretRectForPosition:[textView closestPositionToPoint:selectionCenterPoint withinRange:selectionRange]] inView:textView];
    [menuController setMenuVisible:YES animated:YES];
}

@end
