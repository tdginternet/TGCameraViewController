//
//  UIImage+CameraFilters.m
//  TGCameraViewController
//
//  Created by Bruno Furtado on 16/09/14.
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

@import CoreImage;
#import "UIImage+CameraFilters.h"

static NSString* const kCIColorControls         = @"CIColorControls";
static NSString* const kCIToneCurve             = @"CIToneCurve";
static NSString* const kCIVignette              = @"CIVignette";
static NSString* const kInputContrast           = @"inputContrast";
static NSString* const kInputImage              = @"inputImage";
static NSString* const kInputIntensity          = @"inputIntensity";
static NSString* const kInputPoint0             = @"inputPoint0";
static NSString* const kInputPoint1             = @"inputPoint1";
static NSString* const kInputPoint2             = @"inputPoint2";
static NSString* const kInputPoint3             = @"inputPoint3";
static NSString* const kInputPoint4             = @"inputPoint4";
static NSString* const kInputRadius             = @"inputRadius";
static NSString* const kInputSaturation         = @"inputSaturation";



@implementation UIImage (CameraFilters)

#pragma mark -
#pragma mark - Public methods

- (UIImage *)curveFilter
{
    CIImage *inputImage = [[CIImage alloc] initWithImage:self];
    
    CIFilter *filter = [CIFilter filterWithName:kCIToneCurve];
    [filter setDefaults];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[CIVector vectorWithX:0 Y:0] forKey:kInputPoint0];
    [filter setValue:[CIVector vectorWithX:.25 Y:.15] forKey:kInputPoint1];
    [filter setValue:[CIVector vectorWithX:.5 Y:.5] forKey:kInputPoint2];
    [filter setValue:[CIVector vectorWithX:.75 Y:.85] forKey:kInputPoint3];
    [filter setValue:[CIVector vectorWithX:1 Y:1] forKey:kInputPoint4];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    return [self imageFromContext:context withFilter:filter];
}

- (UIImage *)saturateImage:(CGFloat)saturation withContrast:(CGFloat)contrast
{
    CIImage *inputImage = [[CIImage alloc] initWithImage:self];
    
    NSNumber *saturationNumber = [NSNumber numberWithFloat:saturation];
    NSNumber *contrastNumber = [NSNumber numberWithFloat:contrast];
    
    CIFilter *filter = [CIFilter filterWithName:kCIColorControls];
    [filter setValue:inputImage forKey:kInputImage];
    [filter setValue:saturationNumber forKey:kInputSaturation];
    [filter setValue:contrastNumber forKey:kInputContrast];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    return [self imageFromContext:context withFilter:filter];
}

- (UIImage *)vignetteWithRadius:(CGFloat)radius intensity:(CGFloat)intensity
{
    CIImage *inputImage = [[CIImage alloc] initWithImage:self];
    
    NSNumber *intentisyNumber = [NSNumber numberWithFloat:intensity];
    NSNumber *radiusNumber = [NSNumber numberWithFloat:radius];
    
    CIFilter *filter = [CIFilter filterWithName:kCIVignette];
    [filter setValue:inputImage forKey:kInputImage];
    [filter setValue:intentisyNumber forKey:kInputIntensity];
    [filter setValue:radiusNumber forKey:kInputRadius];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    return [self imageFromContext:context withFilter:filter];
}

#pragma mark -
#pragma mark - Private methods

- (UIImage *)imageFromContext:(CIContext *)context withFilter:(CIFilter *)filter
{
    CIImage *outputImage = [filter outputImage];
    CGRect extent = [filter.outputImage extent];
    
    CGImageRef imageRef = [context createCGImage:outputImage fromRect:extent];
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    
    return image;
}

@end