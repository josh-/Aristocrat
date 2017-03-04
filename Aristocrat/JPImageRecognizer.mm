//
//  JPImageRecognizer.m
//  Aristocrat
//
//  Created by Josh Parnham on 19/04/2014.
//  Based on code Copyright 2007 Angus W Hardie (MalcolmHardie Solutions Ltd.) All rights reserved.
//

#import "JPImageRecognizer.h"

#include <tesseract/baseapi.h>

@implementation JPImageRecognizer

- (NSString *)recognizeImage:(NSImage *)image
{
    if (image == nil) {
        return nil;
    }
    
    // Returns the value of -barcodeContents if that returns a nonzero value, otherwise returns the value of -characterRecognitionContents
    return ([self barcodeContents:image] ?: [self characterRecognitionContents:image]);
}

- (NSString *)barcodeContents:(NSImage *)image
{
    CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)[image TIFFRepresentation], NULL);
    CGImageRef imageRef =  CGImageSourceCreateImageAtIndex(sourceRef, 0, NULL);
    
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageRef];
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
    
    NSError *error = nil;
    
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    
    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap hints:hints error:&error];
    if (result) {
        return result.text;
    }
    return nil;
}

- (NSString *)characterRecognitionContents:(NSImage *)image
{
    NSString *dataPathDirectory = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/"];
    const char *dataPathDirectoryCString = [dataPathDirectory cStringUsingEncoding:NSUTF8StringEncoding];
    setenv("TESSDATA_PREFIX", dataPathDirectoryCString, 1);
    
    tesseract::TessBaseAPI *tess = new tesseract::TessBaseAPI();
    if (tess->Init(dataPathDirectoryCString, "eng")) {
        fprintf(stderr, "Could not initialize tesseract.\n");
        exit(1);
    }
    tess->SetVariable("language_model_penalty_non_dict_word", "0.3");
    tess->SetVariable("language_model_penalty_non_freq_dict_word", "0.2");
    
    NSBitmapImageRep *imageRep;
	NSBitmapImageRep *bestRep = nil;
	NSEnumerator *enumerator = [[image representations] objectEnumerator];
	
    while ((imageRep = [enumerator nextObject]) != nil) {
		if ([imageRep isKindOfClass:[NSBitmapImageRep class]]) {
			bestRep = imageRep;
		}
	}
	
	if (!bestRep) {
		// No representation found, try getting a tiffRepresentation as the last chance
		bestRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
	}
	if (bestRep == nil) {
		// Everything failed and we have no representation
		return nil;
	}
	
	imageRep = bestRep;
	
	NSSize imageSize = NSMakeSize([imageRep pixelsWide], [imageRep pixelsHigh]);
	NSInteger bytesPerLine = [imageRep bytesPerRow];
	
	unsigned char *imageData = [imageRep bitmapData];
	
	char *text = tess->TesseractRect((const unsigned char *)imageData, (int)[imageRep bitsPerPixel]/8, (int)bytesPerLine, 0, 0, imageSize.width, imageSize.height);
	NSString *string = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
	delete(text);
	
	return string;
}

@end
