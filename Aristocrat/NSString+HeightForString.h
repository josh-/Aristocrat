//
//  NSString+HeightForString.h
//  Aristocrat
//
//  Created by Josh Parnham on 25/2/17.
//  Copyright © 2017 Josh Parnham. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HeightForString)

+ (CGFloat)heightForString:(NSString *)string font:(NSFont *)font width:(float)width;

@end
