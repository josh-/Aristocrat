//
//  GeneralPreferencesViewController.m
//  Aristocrat
//
//  Adapted from the MASPreferencesDemo project
//

#import "GeneralPreferencesViewController.h"

#import "JPLaunchAtLoginManager.h"

@implementation GeneralPreferencesViewController

static NSString *const helperApplicationBundleIdentifier = @"com.joshparnham.AristocratHelper";

- (id)init
{
    return [super initWithNibName:@"GeneralPreferencesView" bundle:nil];
}

#pragma mark - MASPreferencesViewController

- (NSString *)identifier
{
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
    return @"General";
}

#pragma mark - Launch at login

- (BOOL)launchAtLogin
{
    return [JPLaunchAtLoginManager willStartAtLogin:helperApplicationBundleIdentifier];
}

- (void)setLaunchAtLogin:(BOOL)enabled
{
    [self willChangeValueForKey:@"launchAtLogin"];
    [JPLaunchAtLoginManager setStartAtLogin:helperApplicationBundleIdentifier enabled:enabled];
    [self didChangeValueForKey:@"launchAtLogin"];
}

@end
