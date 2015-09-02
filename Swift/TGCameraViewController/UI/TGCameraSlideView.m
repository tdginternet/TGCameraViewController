//
//  TGCameraSlideView.m
//  TGCameraViewController
//
//  Created by Bruno Tortato Furtado on 17/09/14.
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

#import "TGCameraSlideView.h"



@interface TGCameraSlideView () <TGCameraSlideViewProtocol>

- (void)showWithAnimationAtView:(UIView *)view completion:(void (^)(void))completion;
- (void)hideWithAnimationAtView:(UIView *)view completion:(void (^)(void))completion;

- (void)addSlideToView:(UIView *)view withOriginY:(CGFloat)originY;

- (void)hideWithAnimationAtView:(UIView *)view
               withTimeInterval:(CGFloat)timeInterval
                     completion:(void (^)(void))completion;

- (void)removeSlideFromSuperview:(BOOL)remove
                    withDuration:(CGFloat)duration
                         originY:(CGFloat)originY
                      completion:(void (^)(void))completion;

@end



@implementation TGCameraSlideView

static NSString* const kExceptionName = @"TGCameraSlideViewException";
static NSString* const kExceptionMessage = @"Invoked abstract method";

#pragma mark -
#pragma mark - Public methods

+ (void)showSlideUpView:(TGCameraSlideView *)slideUpView slideDownView:(TGCameraSlideView *)slideDownView atView:(UIView *)view completion:(void (^)(void))completion
{
    [slideUpView addSlideToView:view withOriginY:[slideUpView finalPosition]];
    [slideDownView addSlideToView:view withOriginY:[slideDownView finalPosition]];
    
    [slideUpView removeSlideFromSuperview:NO withDuration:.15f originY:[slideUpView initialPositionWithView:view] completion:nil];
    [slideDownView removeSlideFromSuperview:NO withDuration:.15f originY:[slideDownView initialPositionWithView:view] completion:completion];
}

+ (void)hideSlideUpView:(TGCameraSlideView *)slideUpView slideDownView:(TGCameraSlideView *)slideDownView atView:(UIView *)view completion:(void (^)(void))completion
{
    [slideUpView hideWithAnimationAtView:view withTimeInterval:.6 completion:nil];
    [slideDownView hideWithAnimationAtView:view withTimeInterval:.6 completion:completion];
}

- (void)showWithAnimationAtView:(UIView *)view completion:(void (^)(void))completion
{
    [self addSlideToView:view
             withOriginY:[self finalPosition]];
    
    [self removeSlideFromSuperview:NO
                      withDuration:.15f
                           originY:[self initialPositionWithView:view]
                        completion:completion];
}

- (void)hideWithAnimationAtView:(UIView *)view completion:(void (^)(void))completion
{
    [self hideWithAnimationAtView:view
                 withTimeInterval:.6
                       completion:completion];
}

#pragma mark -
#pragma mark - TGCameraSlideViewProtocol

- (CGFloat)initialPositionWithView:(UIView *)view
{
    [NSException exceptionWithName:kExceptionName
                            reason:kExceptionMessage
                          userInfo:nil];
    
    return 0.;
}

- (CGFloat)finalPosition
{
    [NSException exceptionWithName:kExceptionName
                            reason:kExceptionMessage
                          userInfo:nil];
    
    return 0.;
}

#pragma mark -
#pragma mark - Private methods

- (void)addSlideToView:(UIView *)view withOriginY:(CGFloat)originY
{
    CGFloat width = CGRectGetWidth(view.frame);
    CGFloat height = CGRectGetHeight(view.frame)/2;
    
    CGRect frame = self.frame;
    frame.size.width = width;
    frame.size.height = height;
    frame.origin.y = originY;
    self.frame = frame;
    
    [view addSubview:self];
}

- (void)hideWithAnimationAtView:(UIView *)view withTimeInterval:(CGFloat)timeInterval completion:(void (^)(void))completion
{
    [self addSlideToView:view withOriginY:[self initialPositionWithView:view]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [NSThread sleepForTimeInterval:timeInterval];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeSlideFromSuperview:YES
                              withDuration:.5
                                   originY:[self finalPosition]
                                completion:completion];
        });
    });
}

- (void)removeSlideFromSuperview:(BOOL)remove withDuration:(CGFloat)duration originY:(CGFloat)originY completion:(void (^)(void))completion
{
    CGRect frame = self.frame;
    frame.origin.y = originY;
    
    [UIView animateWithDuration:duration animations:^{
        self.frame = frame;
    } completion:^(BOOL finished) {
        if (finished) {
            if (remove) {
                [self removeFromSuperview];
            }
            
            if (completion) {
                completion();
            }
        }
    }];
}

@end