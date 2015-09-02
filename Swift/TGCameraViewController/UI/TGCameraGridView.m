//
//  TGCameraGridView.m
//  TGCameraViewController
//
//  Created by Bruno Tortato Furtado on 19/09/14.
//  Copyright (c) 2014 Tudo Gostoso Internet. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "TGCameraGridView.h"
#import "TGCameraColor.h"

@interface TGCameraGridView ()

- (void)setup;

@end



@implementation TGCameraGridView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, [TGCameraColor.grayColor colorWithAlphaComponent:.7].CGColor);
    
    CGFloat columnWidth = self.frame.size.width / (self.numberOfColumns + 1.0);
    CGFloat rowHeight = self.frame.size.height / (self.numberOfRows + 1.0);
    
    for (NSUInteger i = 1; i <= self.numberOfColumns; i++) {
        CGPoint startPoint;
        startPoint.x = columnWidth * i;
        startPoint.y = 0.0f;

        CGPoint endPoint;
        endPoint.x = startPoint.x;
        endPoint.y = self.frame.size.height;
        
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        CGContextStrokePath(context);
    }
 
    for (NSUInteger i = 1; i <= self.numberOfRows; i++) {
        CGPoint startPoint;
        startPoint.x = 0.0f;
        startPoint.y = rowHeight * i;

        CGPoint endPoint;
        endPoint.x = self.frame.size.width;
        endPoint.y = startPoint.y;
        
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        CGContextStrokePath(context);
    }
}

#pragma mark -
#pragma mark - Private methods

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.lineWidth = .8;
}

@end