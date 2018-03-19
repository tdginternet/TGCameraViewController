<p align="center">
  <img src="http://s23.postimg.org/4psw1dtyj/TGCamera_View_Controller.png" alt="TGCameraViewController" title="TGCameraViewController">
</p>

<p align="center">
  <img src="http://s28.postimg.org/eeli1omct/TGCamera_View_Controller.png" alt="TGCameraViewController" title="TGCameraViewController">
</p>

Custom camera with AVFoundation. Beautiful, light and easy to integrate with iOS projects. Compatible with Objective-C and Swift.

[![Build Status](https://api.travis-ci.org/tdginternet/TGCameraViewController.png)](https://api.travis-ci.org/tdginternet/TGCameraViewController.png)&nbsp;
![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)&nbsp;
[![Cocoapods](http://img.shields.io/cocoapods/v/TGCameraViewController.svg)](http://cocoapods.org/pods/TGCameraViewController)&nbsp;
[![Cocoapods](http://img.shields.io/cocoapods/p/TGCameraViewController.svg)](http://cocoapods.org/pods/TGCameraViewController)&nbsp;
[![Analytics](https://ga-beacon.appspot.com/UA-54929747-1/tdginternet/TGCameraViewController/README.md)](https://github.com/igrigorik/ga-beacon)

* Completely custom camera with AVFoundation
* Custom view with camera permission denied
* Custom button colors
* Easy way to access album (camera roll)
* Flash auto, off and on
* Focus
* Front and back camera
* Grid view
* Preview photo view with three filters (fast processing)
* Visual effects like Instagram iOS app
* iPhone, iPod and iPad supported

Requirements: iOS 8 or higher.

### Who uses it

Find out [who uses TGCameraViewController](https://github.com/tdginternet/TGCameraViewController/wiki/WHO-USES) and add your app to the list.


### Adding to your project

[CocoaPods](http://cocoapods.org) is the recommended way to add TGCameraViewController to your project.

Add a `pod` entry for TGCameraViewController to your Podfile:

```
pod 'TGCameraViewController'
```

Install the pod by running:

```
pod install
```

Alternatively, you can download the [latest code version](https://github.com/tdginternet/TGCameraViewController/archive/master.zip) directly and import the files to your project.

#### Privacy (iOS 10)

If you are building your app with iOS 10 or newer, you need to add two privacy keys to your app's Info.plist to allow the usage of the camera and photo library, or your app will crash. 

Add the keys below to the `<dict>` tag of your Info.plist, replacing the strings with the description you want to provide when prompting the user:

```
	<key>NSPhotoLibraryUsageDescription</key>
	<string>Enable Photos access to import photos from your library.</string>
	<key>NSCameraUsageDescription</key>
	<string>Enable Camera to take photos.</string>
```


### Usage

Here are some usage examples with Objective-C. You can find example projects for **Objective-C** and **Swift 3** cloning the project. Refer to version 2.2.5 if you need a Swift 2.3 example.

#### Take photo


```obj-c
#import "TGCameraViewController.h"

@interface TGViewController : UIViewController <TGCameraDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *photoView;

- (IBAction)takePhotoTapped;

@end



@implementation TGViewController

- (IBAction)takePhotoTapped
{
    TGCameraNavigationController *navigationController =
    [TGCameraNavigationController newWithCameraDelegate:self];

    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - TGCameraDelegate optional

- (void)cameraWillTakePhoto
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)cameraDidSavePhotoAtPath:(NSURL *)assetURL
{
    // When this method is implemented, an image will be saved on the user's device
    NSLog(@"%s album path: %@", __PRETTY_FUNCTION__, assetURL);
}

- (void)cameraDidSavePhotoWithError:(NSError *)error
{
    NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
}

#pragma mark - TGCameraDelegate required

- (void)cameraDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidTakePhoto:(UIImage *)image
{
    _photoView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidSelectAlbumPhoto:(UIImage *)image
{
    _photoView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
```

#### Choose photo

```obj-c
#import "TGCameraViewController.h"

@interface TGViewController : UIViewController
<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *photoView;

- (IBAction)chooseExistingPhotoTapped;

@end



@implementation TGViewController

- (IBAction)chooseExistingPhotoTapped
{
    UIImagePickerController *pickerController =
    [TGAlbum imagePickerControllerWithDelegate:self];

    [self presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _photoView.image = [TGAlbum imageWithMediaInfo:info];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
```

#### Change colors

```obj-c
@implementation TGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *tintColor = [UIColor greenColor];
    [TGCameraColor setTintColor:tintColor];
}

@end
```

#### Options

|Option|Type|Default|Description|
|:-:|:-:|:-:|:-:|
|kTGCameraOptionHiddenToggleButton|NSNumber (YES/NO)|NO|Displays or hides the button that switches between the front and rear camera|
|kTGCameraOptionHiddenAlbumButton|NSNumber (YES/NO)|NO|Displays or hides the button that allows the user to select a photo from their album|
|kTGCameraOptionHiddenFilterButton|NSNumber (YES/NO)|NO|Displays or hides the button that allos the user to filter their photo|
|kTGCameraOptionSaveImageToAlbum|NSNumber (YES/NO)|NO|Save or not the photo in the camera roll|
|kTGCameraOptionUseOriginalAspect|NSNumber (YES/NO)|NO|Use the original aspect instead of cropping the image to a square|
|kTGCameraOptionUseDefaultStatusBarVisibility|NSNumber (YES/NO)|NO|Use current app settings for status bar

```obj-c
#import "TGCamera.h"

@implementation UIViewController

- (void)viewDidLoad
{
    //...
    [TGCamera setOption:kTGCameraOptionHiddenToggleButton value:@YES];
    [TGCamera setOption:kTGCameraOptionHiddenAlbumButton value:@YES];
    [TGCamera setOption:kTGCameraOptionHiddenFilterButton value:@YES];
    [TGCamera setOption:kTGCameraOptionSaveImageToAlbum value:@YES];
    //...
}

- (IBAction)buttonTapped
{
    //...
    BOOL hiddenToggleButton = [[TGCamera getOption:kTGCameraOptionHiddenToggleButton] boolValue];
    BOOL hiddenAlbumButton = [[TGCamera getOption:kTGCameraOptionHiddenAlbumButton] boolValue];
    BOOL hiddenFilterButton = [[TGCamera getOption:kTGCameraOptionHiddenFilterButton] boolValue];
    BOOL saveToDevice = [[TGCamera getOption:kTGCameraOptionSaveImageToAlbum] boolValue];
    //...    
}

@end
```


### Requirements

TGCameraViewController works on iOS 8.0+ version and is compatible with ARC projects. It depends on the following Apple frameworks, which should already be included with most Xcode templates:

* AssetsLibrary.framework
* AVFoundation.framework
* CoreImage.framework
* Foundation.framework
* MobileCoreServices.framework
* UIKit.framework

You will need LLVM 3.0 or later in order to build TGCameraViewController.



### To do

* Landscape mode support
* Zoom
* Image size as global parameter
* Fast animations
* Create a custom picker controller
* Zoom does not work with the camera roll pictures



### License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).



### Change log

A brief summary of each TGCameraViewController release can be found on the [releases](https://github.com/tdginternet/TGCameraViewController/releases).
