//
//  TGCameraFunctions.h
//  TGCameraViewController
//
//  Created by Bruno Furtado on 27/05/15.
//  Copyright (c) 2015 Tudo Gostoso Internet. All rights reserved.
//

#import "TGCameraViewController.h"

NSString *TGLocalizedString(NSString* key) {
    static NSBundle *bundle = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSString *path = [[NSBundle bundleForClass:[TGCameraViewController class]] pathForResource:@"TGCameraViewController" ofType:@"bundle"];
        bundle = [[NSBundle alloc] initWithPath:path];
    });
    return [bundle localizedStringForKey:key value:key table:nil];
}