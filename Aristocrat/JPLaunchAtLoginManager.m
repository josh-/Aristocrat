//
//  JPLaunchAtLoginManager.m
//  Aristocrat
//
//  Created by Josh Parnham on 20/02/2017.
//  Copyright (c) 2017 Josh Parnham. All rights reserved.
//

#import "JPLaunchAtLoginManager.h"

@implementation JPLaunchAtLoginManager

+ (BOOL)willStartAtLogin:(NSString *)bundleIdentifier
{
    NSArray *jobDictionary = CFBridgingRelease(SMCopyAllJobDictionaries(kSMDomainUserLaunchd));
    for (NSDictionary *job in jobDictionary) {
        if ([[job objectForKey:@"Label"] isEqualToString:bundleIdentifier]) {
            return [[job objectForKey:@"OnDemand"] boolValue];
        }
    }
    return NO;
}

+ (void)setStartAtLogin:(NSString *)bundleIdentifier enabled:(BOOL)enabled
{
    if (!SMLoginItemSetEnabled((__bridge CFStringRef)bundleIdentifier, enabled)) {
        NSLog(@"Setting login item to %i was not successful", enabled);
    }
}

@end
