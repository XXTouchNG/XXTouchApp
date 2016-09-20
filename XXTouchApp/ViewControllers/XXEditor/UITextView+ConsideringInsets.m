//
//  UITextView+ConsideringInsets.m
//  XXTouchApp
//
//  Created by Zheng on 9/20/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "UITextView+ConsideringInsets.h"

@implementation UITextView (ConsideringInsets)

- (void)scrollRangeToMiddle:(NSRange)range height:(CGFloat)height {
    UITextPosition *startPosition = [self positionFromPosition:self.beginningOfDocument offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:startPosition offset:range.length];
    UITextRange *textRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    CGRect rect = [self firstRectForRange:textRange];
    CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y - height, rect.size.width, rect.size.height + height);
    [self scrollRectToVisible:newRect animated:YES];
}

// Scrolls to visible range, eventually considering insets
- (void)scrollRangeToVisible:(NSRange)range consideringInsets:(BOOL)considerInsets
{
    if (considerInsets && (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1))
    {
        // Calculates rect for range
        UITextPosition *startPosition = [self positionFromPosition:self.beginningOfDocument offset:range.location];
        UITextPosition *endPosition = [self positionFromPosition:startPosition offset:range.length];
        UITextRange *textRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
        CGRect rect = [self firstRectForRange:textRange];
        
        // Scrolls to visible rect
        [self scrollRectToVisible:rect animated:YES consideringInsets:YES];
    }
    else
        [self scrollRangeToVisible:range];
}

// Scrolls to visible rect, eventually considering insets
- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated consideringInsets:(BOOL)considerInsets
{
    if (considerInsets && (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1))
    {
        // Gets bounds and calculates visible rect
        CGRect bounds = self.bounds;
        UIEdgeInsets contentInset = self.contentInset;
        CGRect visibleRect = [self visibleRectConsideringInsets:YES];
        
        // Do not scroll if rect is on screen
        if (!CGRectContainsRect(visibleRect, rect))
        {
            CGPoint contentOffset = self.contentOffset;
            // Calculates new contentOffset
            if (rect.origin.y < visibleRect.origin.y)
                // rect precedes bounds, scroll up
                contentOffset.y = rect.origin.y - contentInset.top;
            else
                // rect follows bounds, scroll down
                contentOffset.y = rect.origin.y + contentInset.bottom + rect.size.height - bounds.size.height;
            [self setContentOffset:contentOffset animated:animated];
        }
    }
    else
        [self scrollRectToVisible:rect animated:animated];
}

// Returns visible rect, eventually considering insets
- (CGRect)visibleRectConsideringInsets:(BOOL)considerInsets
{
    CGRect bounds = self.bounds;
    if (considerInsets)
    {
        UIEdgeInsets contentInset = self.contentInset;
        CGRect visibleRect = self.bounds;
        visibleRect.origin.x += contentInset.left;
        visibleRect.origin.y += contentInset.top;
        visibleRect.size.width -= (contentInset.left + contentInset.right);
        visibleRect.size.height -= (contentInset.top + contentInset.bottom);
        return visibleRect;
    }
    return bounds;
}

@end
