//
//  TGCameraToggle.m
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

#import "TGCameraToggle.h"

@interface TGCameraToggle ()

+ (AVCaptureDeviceInput *)reverseDeviceInput:(AVCaptureDeviceInput *)deviceInput;

@end



@implementation TGCameraToggle

#pragma mark -
#pragma mark - Public methods

+ (void)toogleWithCaptureSession:(AVCaptureSession *)session
{
    AVCaptureDeviceInput *deviceInput = [session.inputs lastObject];
    AVCaptureDeviceInput *reverseDeviceInput = [self reverseDeviceInput:deviceInput];
    
    [session beginConfiguration];
    [session removeInput:deviceInput];
    [session addInput:reverseDeviceInput];
    [session commitConfiguration];
}

#pragma mark -
#pragma mark - Private methods

+ (AVCaptureDeviceInput *)reverseDeviceInput:(AVCaptureDeviceInput *)deviceInput
{
    //
    // reverse device position
    //
    
    AVCaptureDevicePosition reversePosition;
    
    if ([deviceInput.device position] == AVCaptureDevicePositionFront) {
        reversePosition = AVCaptureDevicePositionBack;
    } else {
        reversePosition = AVCaptureDevicePositionFront;
    }
    
    //
    // find device with reverse position
    //
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *reverseDevice = nil;
    
    for (AVCaptureDevice *device in devices) {
        if ([device position] == reversePosition) {
            reverseDevice = device;
            break;
        }
    }

    //
    // reverse device input
    //
    
    return  [AVCaptureDeviceInput deviceInputWithDevice:reverseDevice error:nil];
}

@end