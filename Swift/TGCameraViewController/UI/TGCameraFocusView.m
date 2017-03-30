//
//  TGCameraFocusView.m
//  TGCameraViewController
//
//  Created by iOS软件工程师 曾宪华 on 14-10-10.
//  Copyright (c) 2014年 Tudo Gostoso Internet. All rights reserved.
//

#import "TGCameraFocusView.h"
#import "TGCameraColor.h"

@implementation TGCameraFocusView

#pragma mark - Left Cycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeScaleToFill;
        
        //
        // create view and subview to focus
        //
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TGCameraFocusSize, TGCameraFocusSize)];
        UIView *subview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TGCameraFocusSize - 20, TGCameraFocusSize - 20)];
        
        view.tag = subview.tag = -1;
        view.center = subview.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        view.layer.borderColor = subview.layer.borderColor = [TGCameraColor orangeColor].CGColor;
        
        view.layer.borderWidth = 1;
        view.layer.cornerRadius = CGRectGetHeight(view.frame) / 2;
        
        subview.layer.borderWidth = 5;
        subview.layer.cornerRadius = CGRectGetHeight(subview.frame) / 2;
        
        //[focusView.subviews.lastObject removeFromSuperview];
        //[focusView.subviews.lastObject removeFromSuperview];
        
        //
        // add focus view and focus subview to touch viiew
        //
        
        [self addSubview:view];
        [self addSubview:subview];
    }
    return self;
}

#pragma mark - Animation Method

- (void)startAnimation
{
    [self.layer removeAllAnimations];
    
    self.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    self.alpha = 0;
    
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.transform = CGAffineTransformIdentity;
        self.alpha = 1;
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
            
            self.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
            self.alpha = 1;
            
        } completion:^(BOOL finished1) {
        }];
    }];
}

- (void)stopAnimation
{
    [self.layer removeAllAnimations];
    
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
    }];
}
@end
