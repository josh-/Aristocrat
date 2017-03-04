//
//  AppDelegate.m
//  AristocratHelper
//
//  Created by Josh Parnham on 20/2/17.
//  Copyright © 2017 Josh Parnham. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Credit to http://martiancraft.com/blog/2015/01/login-items/
    
    NSArray *pathComponents = [[[NSBundle mainBundle] bundlePath] pathComponents];
    pathComponents = [pathComponents subarrayWithRange:NSMakeRange(0, [pathComponents count] - 4)];
    NSString *path = [NSString pathWithComponents:pathComponents];
    [[NSWorkspace sharedWorkspace] launchApplication:path];
    [NSApp terminate:nil];
}

@end
