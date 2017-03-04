//
//  JPImageRecognizer.h
//  Aristocrat
//
//  Created by Josh Parnham on 19/04/2014.
//  Based on code Copyright 2007 Angus W Hardie (MalcolmHardie Solutions Ltd.) All rights reserved.
//

//#import <Tesseract/baseapi.h>

#import "ZXingObjC/ZXingObjC.h"

@interface JPImageRecognizer : NSObject

- (NSString *)recognizeImage:(NSImage *)image;

@end
