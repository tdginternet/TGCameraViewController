//
//  TGAssetsLibrary.h
//  TGCameraViewController
//
//  Created by Bruno Furtado on 17/09/14.
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

@import AssetsLibrary;
#import "TGAssetImageFile.h"

typedef void(^TGAssetsResultCompletion)(NSURL *assetURL);
typedef void(^TGAssetsFailureCompletion)(NSError* error);
typedef void(^TGAssetsLoadImagesCompletion)(NSArray *items, NSError *error);



@interface TGAssetsLibrary : ALAssetsLibrary

+ (instancetype) new __attribute__
((unavailable("[+new] is not allowed, use [+defaultAssetsLibrary]")));

- (instancetype) init __attribute__
((unavailable("[-init] is not allowed, use [+defaultAssetsLibrary]")));

+ (TGAssetsLibrary *)defaultAssetsLibrary;

- (void)deleteFile:(TGAssetImageFile *)file;

- (NSArray *)loadImagesFromDocumentDirectory;
- (void)loadImagesFromAlbum:(NSString *)albumName withCallback:(TGAssetsLoadImagesCompletion)callback;

- (void)saveImage:(UIImage *)image resultBlock:(TGAssetsResultCompletion)resultBlock failureBlock:(TGAssetsFailureCompletion)failureBlock;
- (void)saveImage:(UIImage *)image withAlbumName:(NSString *)albumName resultBlock:(TGAssetsResultCompletion)resultBlock failureBlock:(TGAssetsFailureCompletion)failureBlock;
- (void)saveJPGImageAtDocumentDirectory:(UIImage *)image resultBlock:(TGAssetsResultCompletion)resultBlock failureBlock:(TGAssetsFailureCompletion)failureBlock;

@end