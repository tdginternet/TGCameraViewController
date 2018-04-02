//
//  TGCameraViewController.m
//  TGCameraViewController
//
//  Created by Bruno Tortato Furtado on 13/09/14.
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

#import "TGCameraViewController.h"
#import "TGPhotoViewController.h"
#import "TGCameraSlideView.h"
#import "TGTintedButton.h"


@interface TGCameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *captureView;
@property (strong, nonatomic) IBOutlet UIImageView *topLeftView;
@property (strong, nonatomic) IBOutlet UIImageView *topRightView;
@property (strong, nonatomic) IBOutlet UIImageView *bottomLeftView;
@property (strong, nonatomic) IBOutlet UIImageView *bottomRightView;
@property (strong, nonatomic) IBOutlet UIView *separatorView;
@property (strong, nonatomic) IBOutlet UIView *actionsView;
@property (strong, nonatomic) IBOutlet TGTintedButton *closeButton;
@property (strong, nonatomic) IBOutlet TGTintedButton *gridButton;
@property (strong, nonatomic) IBOutlet TGTintedButton *toggleButton;
@property (strong, nonatomic) IBOutlet TGTintedButton *shotButton;
@property (strong, nonatomic) IBOutlet TGTintedButton *albumButton;
@property (strong, nonatomic) IBOutlet UIButton *flashButton;
@property (strong, nonatomic) IBOutlet TGCameraSlideView *slideUpView;
@property (strong, nonatomic) IBOutlet TGCameraSlideView *slideDownView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeightFixed;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeightFill;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toggleButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captureViewAspect;

@property (strong, nonatomic) TGCamera *camera;
@property (nonatomic) BOOL wasLoaded;

- (IBAction)closeTapped;
- (IBAction)gridTapped;
- (IBAction)flashTapped;
- (IBAction)shotTapped;
- (IBAction)albumTapped;
- (IBAction)toggleTapped;
- (IBAction)handleTapGesture:(UITapGestureRecognizer *)recognizer;
- (IBAction)handlePinchZoom:(UIPinchGestureRecognizer *)pinchRecognizer;

- (void)deviceOrientationDidChangeNotification;
- (AVCaptureVideoOrientation)videoOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation;
- (void)viewWillDisappearWithCompletion:(void (^)(void))completion;

@end



@implementation TGCameraViewController

- (instancetype)init
{
    return [super initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (CGRectGetHeight([[UIScreen mainScreen] bounds]) <= 480) {
        _topViewHeight.constant = 0;
    }
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (devices.count > 1) {
        if ([[TGCamera getOption:kTGCameraOptionHiddenToggleButton] boolValue] == YES) {
            _toggleButton.hidden = YES;
            _toggleButtonWidth.constant = 0;
        }
    } else {  
        if ([[TGCamera getOption:kTGCameraOptionHiddenToggleButton] boolValue] == YES) {
            _toggleButton.hidden = YES;
            _toggleButtonWidth.constant = 0;
        }
    }
    
    if ([[TGCamera getOption:kTGCameraOptionHiddenAlbumButton] boolValue] == YES) {
        _albumButton.hidden = YES;
    }

    if ([[TGCamera getOption:kTGCameraOptionUseOriginalAspect] boolValue] == YES) {
        _bottomViewHeightFixed.active = YES;
        _captureViewAspect.active = NO;
    } else {
        _bottomViewHeightFixed.active = NO;
    }
    
    [_albumButton.layer setCornerRadius:10.f];
    [_albumButton.layer setMasksToBounds:YES];
    
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    [_closeButton setImage:[UIImage imageNamed:@"CameraClose" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_shotButton setImage:[UIImage imageNamed:@"CameraShot" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_albumButton setImage:[UIImage imageNamed:@"CameraRoll" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_gridButton setImage:[UIImage imageNamed:@"CameraGrid" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_toggleButton setImage:[UIImage imageNamed:@"CameraToggle" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    _camera = [TGCamera cameraWithFlashButton:_flashButton];
    
    _captureView.backgroundColor = [UIColor clearColor];
    
    _topLeftView.transform = CGAffineTransformMakeRotation(0);
    _topRightView.transform = CGAffineTransformMakeRotation(M_PI_2);
    _bottomLeftView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    _bottomRightView.transform = CGAffineTransformMakeRotation(M_PI_2*2);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    _separatorView.hidden = NO;
    
    _actionsView.hidden = YES;
    
    _topLeftView.hidden =
    _topRightView.hidden =
    _bottomLeftView.hidden =
    _bottomRightView.hidden = YES;
    
    _gridButton.enabled =
    _toggleButton.enabled =
    _shotButton.enabled =
    _albumButton.enabled =
    _flashButton.enabled = NO;
    
    [_camera startRunning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self deviceOrientationDidChangeNotification];
    
    _separatorView.hidden = YES;
    
    [TGCameraSlideView hideSlideUpView:_slideUpView slideDownView:_slideDownView atView:_captureView completion:^{
        _topLeftView.hidden =
        _topRightView.hidden =
        _bottomLeftView.hidden =
        _bottomRightView.hidden = NO;
        
        _actionsView.hidden = NO;
        
        _gridButton.enabled =
        _toggleButton.enabled =
        _shotButton.enabled =
        _albumButton.enabled =
        _flashButton.enabled = YES;
    }];
    
    if (_wasLoaded == NO) {
        _wasLoaded = YES;
        [_camera insertSublayerWithCaptureView:_captureView atRootView:self.view];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_camera stopRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark -
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *photo = [TGAlbum imageWithMediaInfo:info];
    
    TGPhotoViewController *viewController = [TGPhotoViewController newWithDelegate:_delegate photo:photo];
    [viewController setAlbumPhoto:YES];
    [self.navigationController pushViewController:viewController animated:NO];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)closeTapped
{
    if ([_delegate respondsToSelector:@selector(cameraDidCancel)]) {
        [_delegate cameraDidCancel];
    }
}

- (IBAction)handlePinchZoom:(UIPinchGestureRecognizer *)pinchRecognizer{
    AVCaptureDevice *device =[AVCaptureDevice defaultDeviceWithMediaType:
                              AVMediaTypeVideo];
    AVCaptureDeviceFormat *format = device.activeFormat;
    CGFloat maxZoomFactor = format.videoMaxZoomFactor;
    NSArray *formats = device.formats;
    const CGFloat pinchVelocityDividerFactor = 10.0f;
    if (pinchRecognizer.state == UIGestureRecognizerStateChanged || pinchRecognizer.state == UIGestureRecognizerStateBegan) {
        NSError *error = nil;
        if (![device lockForConfiguration:&error]) {
            NSLog(@"error: %@", error);
            return;
        }
        CGFloat desiredZoomFactor = device.videoZoomFactor +
        atan2f(pinchRecognizer.velocity, pinchVelocityDividerFactor);
        
        device.videoZoomFactor =   MAX(1.0, MIN(desiredZoomFactor,
                                                device.activeFormat.videoMaxZoomFactor));
        [device unlockForConfiguration];
    }
}

- (IBAction)gridTapped
{
    [_camera displayGridView];
}

- (IBAction)flashTapped
{
    [_camera changeFlashModeWithButton:_flashButton];
}

- (IBAction)shotTapped
{
#if !TARGET_IPHONE_SIMULATOR
    _shotButton.enabled =
    _albumButton.enabled = NO;
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation videoOrientation = [self videoOrientationForDeviceOrientation:deviceOrientation];
    
    CGSize cropSize;
    if ([[TGCamera getOption:kTGCameraOptionUseOriginalAspect] boolValue] == YES) {
        cropSize = CGSizeZero;
    } else {
        cropSize = _captureView.frame.size;
    }
    
    dispatch_group_t group = dispatch_group_create();
    __block UIImage *photo;
    
    dispatch_group_enter(group);
    [self viewWillDisappearWithCompletion:^{
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [_camera takePhotoWithCaptureView:_captureView videoOrientation:videoOrientation cropSize:cropSize completion:^(UIImage *_photo) {
        photo = _photo;
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        TGPhotoViewController *viewController = [TGPhotoViewController newWithDelegate:_delegate photo:photo];
        [self.navigationController pushViewController:viewController animated:YES];
    });
#endif
}

- (IBAction)albumTapped
{
    _shotButton.enabled =
    _albumButton.enabled = NO;
    
    [self viewWillDisappearWithCompletion:^{
        UIImagePickerController *pickerController = [TGAlbum imagePickerControllerWithDelegate:self];
        pickerController.popoverPresentationController.sourceView = self.albumButton;
        [self presentViewController:pickerController animated:YES completion:nil];
    }];
}

- (IBAction)toggleTapped
{
    [_camera toogleWithFlashButton:_flashButton];
}

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)recognizer
{
    CGPoint touchPoint = [recognizer locationInView:_captureView];
    [_camera focusView:_captureView inTouchPoint:touchPoint];
}

#pragma mark -
#pragma mark - Private methods

- (void)deviceOrientationDidChangeNotification
{
    UIDeviceOrientation orientation = [UIDevice.currentDevice orientation];
    NSInteger degrees;
    
    switch (orientation) {
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationUnknown:
            degrees = 0;
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            degrees = 90;
            break;
            
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationPortraitUpsideDown:
            degrees = 180;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            degrees = 270;
            break;
    }
    
    CGFloat radians = degrees * M_PI / 180;
    CGAffineTransform transform = CGAffineTransformMakeRotation(radians);
    
    [UIView animateWithDuration:.5f animations:^{
        _gridButton.transform =
        _toggleButton.transform =
        _albumButton.transform =
        _flashButton.transform = transform;
    }];
}

- (AVCaptureVideoOrientation)videoOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation) deviceOrientation;
    
    switch (deviceOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            result = AVCaptureVideoOrientationLandscapeRight;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            result = AVCaptureVideoOrientationLandscapeLeft;
            break;
            
        default:
            break;
    }
    
    return result;
}

- (void)viewWillDisappearWithCompletion:(void (^)(void))completion
{
    _actionsView.hidden = YES;
    
    [TGCameraSlideView showSlideUpView:_slideUpView slideDownView:_slideDownView atView:_captureView completion:^{
        completion();
    }];
}

@end
