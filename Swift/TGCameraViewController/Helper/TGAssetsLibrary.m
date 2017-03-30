//
//  TGAssetsLibrary.m
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

#import "TGAssetsLibrary.h"

@interface TGAssetsLibrary ()

- (void)addAssetURL:(NSURL *)assetURL toAlbum:(NSString *)albumName resultBlock:(TGAssetsResultCompletion)resultBlock failureBlock:(TGAssetsFailureCompletion)failureBlock;
- (NSString *)directory;

@end



@implementation TGAssetsLibrary

#pragma mark -
#pragma mark - Public methods

+ (TGAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static TGAssetsLibrary *library = nil;
    
    dispatch_once(&pred, ^{
        library = [[self alloc] init];
    });
    
    return library;
}

- (void)deleteFile:(TGAssetImageFile *)file
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager isDeletableFileAtPath:file.path]) {
        [fileManager removeItemAtPath:file.path error:nil];
    }
}

- (NSArray *)loadImagesFromDocumentDirectory
{
    NSString *directory = [self directory];
    
    if (directory == nil) {
        return nil;
    }
    
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&error];
    
    if (error) {
        return nil;
    }
    
    NSMutableArray *items = [NSMutableArray new];
    
    for (NSString *name in contents) {
        NSString *path = [directory stringByAppendingPathComponent:name];
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        if (data == nil) {
            continue;
        }
        
        UIImage *image = [UIImage imageWithData:data];
        TGAssetImageFile *file = [[TGAssetImageFile alloc] initWithPath:path image:image];
        [items addObject:file];
    }
    
    return items;
}

- (void)loadImagesFromAlbum:(NSString *)albumName withCallback:(TGAssetsLoadImagesCompletion)callback
{
    __block NSMutableArray *items = [NSMutableArray new];
    
    [self enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    TGAssetImageFile *file = [TGAssetImageFile new];
                    ALAssetRepresentation *representation = [result defaultRepresentation];
                    file.image = [UIImage imageWithCGImage:[representation fullScreenImage] scale:[representation scale] orientation:0];
                    file.path = [[result.defaultRepresentation url] absoluteString];
                    [items addObject:file];
                }
                
                callback(items, nil);
            }];
        }
    } failureBlock:^(NSError *error) {
        callback(items, nil);
    }];
    
}

- (void)saveImage:(UIImage *)image resultBlock:(TGAssetsResultCompletion)resultBlock failureBlock:(TGAssetsFailureCompletion)failureBlock;
{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    [self saveImage:image withAlbumName:appName resultBlock:resultBlock failureBlock:failureBlock];
}

- (void)saveImage:(UIImage *)image withAlbumName:(NSString *)albumName resultBlock:(TGAssetsResultCompletion)resultBlock failureBlock:(TGAssetsFailureCompletion)failureBlock;
{
    [self writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)image.imageOrientation
    completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error && failureBlock) {
            failureBlock(error);
            return;
        }
        
        [self addAssetURL:assetURL toAlbum:albumName resultBlock:resultBlock failureBlock:failureBlock];
    }];
}

- (void)saveJPGImageAtDocumentDirectory:(UIImage *)image resultBlock:(TGAssetsResultCompletion)resultBlock failureBlock:(TGAssetsFailureCompletion)failureBlock
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH:mm:SSSSZ"];
    
    NSString *directory = [self directory];
    
    if (!directory) {
        failureBlock(nil);
        return;
    }
    
    NSString *fileName = [[dateFormatter stringFromDate:[NSDate date]] stringByAppendingPathExtension:@"jpg"];
    NSString *filePath = [directory stringByAppendingString:fileName];
    
    if (filePath == nil) {
        failureBlock(nil);
        return;
    }
    
    NSData *data = UIImageJPEGRepresentation(image, 1);
    [data writeToFile:filePath atomically:YES];
    
    NSURL *assetURL = [NSURL URLWithString:filePath];
    
    resultBlock(assetURL);
}

#pragma mark -
#pragma mark - Private methods

- (void)addAssetURL:(NSURL *)assetURL toAlbum:(NSString *)albumName resultBlock:(TGAssetsResultCompletion)resultBlock failureBlock:(TGAssetsFailureCompletion)failureBlock
{
    __block BOOL albumWasFound = NO;
    
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
            albumWasFound = YES;
            
            [self assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                [group addAsset:asset];

                if (resultBlock) {
                    resultBlock(assetURL);
                }
            } failureBlock:failureBlock];
            
            return;
        }
        
        if (group == nil && albumWasFound == NO) {
            __weak ALAssetsLibrary *weakSelf = self;
            
            [self addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
                [weakSelf assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                    [group addAsset:asset];
                    
                    if (resultBlock) {
                        resultBlock(assetURL);
                    }
                } failureBlock:failureBlock];
            } failureBlock:failureBlock];
        }
    } failureBlock:failureBlock];
}

- (NSString *)directory
{
    NSMutableString *path = [NSMutableString new];
    [path appendString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
    [path appendString:@"/Images/"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
        
        if (error) {
            return nil;
        }
    }
    
    return path;
}

@end