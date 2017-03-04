//
//  NSString+HeightForString.m
//  Aristocrat
//
//  Created by Josh Parnham on 25/2/17.
//  Copyright © 2017 Josh Parnham. All rights reserved.
//

#import "NSString+HeightForString.h"

@implementation NSString (HeightForString)

+ (CGFloat)heightForString:(NSString *)string font:(NSFont *)font width:(float)width
{
    //Based on http://stackoverflow.com/a/1993376/446039
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:string];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(width, FLT_MAX)];
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [textStorage addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [textStorage length])];
    
    (void)[layoutManager glyphRangeForTextContainer:textContainer];
    return [layoutManager usedRectForTextContainer:textContainer].size.height;
}

@end
