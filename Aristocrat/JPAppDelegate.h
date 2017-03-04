//
//  JPAppDelegate.h
//  Aristocrat
//
//  Created by Josh Parnham on 7/03/2014.
//  Copyright (c) 2014 Josh Parnham. All rights reserved.
//

#import "VDKQueue.h"

#import <MASShortcut/Shortcut.h>

@interface JPAppDelegate : NSObject <NSApplicationDelegate, NSSharingServiceDelegate, NSMenuDelegate, VDKQueueDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSMenu *menu;

@property (strong, nonatomic) NSWindowController *preferencesWindowController;

@property (nonatomic, weak) IBOutlet NSButton *unhyphenateRemoveLineBreaksView;
@property (nonatomic, weak) IBOutlet MASShortcutView *captureHotkeyView;
@property (nonatomic, weak) IBOutlet MASShortcutView *captureCopyHotkeyView;
//@property (nonatomic, weak) IBOutlet NSButton *launchAtLoginView;
//
//@property (nonatomic) BOOL startAtLogin;

@end
