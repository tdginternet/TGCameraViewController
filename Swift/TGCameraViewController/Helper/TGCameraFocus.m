//
//  TGCameraFocus.m
//  TGCameraViewController
//
//  Created by Bruno Tortato Furtado on 14/09/14.
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

@import AVFoundation;
@import UIKit;
#import "TGCameraFocusView.h"
#import "TGCameraFocus.h"

@interface TGCameraFocus ()

+ (CGPoint)pointOfInterestWithTouchPoint:(CGPoint)touchPoint;
+ (void)showFocusView:(UIView *)focusView withTouchPoint:(CGPoint)touchPoint andDevice:(AVCaptureDevice *)device;

@end



@implementation TGCameraFocus

#pragma mark -
#pragma mark - Public methods

+ (void)focusWithCaptureSession:(AVCaptureSession *)session touchPoint:(CGPoint)touchPoint inFocusView:(UIView *)focusView
{
    AVCaptureDevice *device = [session.inputs.lastObject device];
    
    [self showFocusView:focusView withTouchPoint:touchPoint andDevice:device];
    
    if ([device lockForConfiguration:nil]) {
        CGPoint pointOfInterest = [self pointOfInterestWithTouchPoint:touchPoint];
        
        if (device.focusPointOfInterestSupported) {
            device.focusPointOfInterest = pointOfInterest;
        }
        
        if (device.exposurePointOfInterestSupported) {
            device.exposurePointOfInterest = pointOfInterest;
        }
        
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        
        if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        
        [device unlockForConfiguration];
    }
}

#pragma mark -
#pragma mark - Private methods

+ (CGPoint)pointOfInterestWithTouchPoint:(CGPoint)touchPoint
{
    CGSize screenSize = [UIScreen.mainScreen bounds].size;
    
    CGPoint pointOfInterest;
    pointOfInterest.x = touchPoint.x / screenSize.width;
    pointOfInterest.y = touchPoint.y / screenSize.height;
    
    return pointOfInterest;
}

+ (void)showFocusView:(UIView *)focusView withTouchPoint:(CGPoint)touchPoint andDevice:(AVCaptureDevice *)device
{
    
    //
    // add focus view animated
    //
    TGCameraFocusView *cameraFocusView = [[TGCameraFocusView alloc] initWithFrame:CGRectMake(0, 0, TGCameraFocusSize, TGCameraFocusSize)];
    cameraFocusView.center = touchPoint;
    [focusView addSubview:cameraFocusView];
    [cameraFocusView startAnimation];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [NSThread sleepForTimeInterval:.5f];
        
        while ([device isAdjustingFocus] ||
               [device isAdjustingExposure] ||
               [device isAdjustingWhiteBalance]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //
            // remove focus view and focus subview animated
            //
            [cameraFocusView stopAnimation];
        });
    });
}

@end