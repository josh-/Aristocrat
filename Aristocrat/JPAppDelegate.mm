//
//  JPAppDelegate.m
//  Aristocrat
//
//  Created by Josh Parnham on 7/03/2014.
//  Copyright (c) 2014 Josh Parnham. All rights reserved.
//

#import "JPAppDelegate.h"
#import "JPImageRecognizer.h"
#import "JPLicencesWindow.h"

#import "NSString+HeightForString.h"

#import "NSSharingServicePicker+ESSSharingServicePickerMenu.h"

#import <MASPreferences/MASPreferencesWindowController.h>
#import "GeneralPreferencesViewController.h"

@interface JPAppDelegate ()

@property (assign) BOOL shouldCopy;

@property (nonatomic) BOOL captureShortcutEnabled;
@property (nonatomic) BOOL captureCopyShortcutEnabled;

@property (nonatomic, assign) NSString *recognizedString;

@property (nonatomic, strong) NSPanel *modifiedAboutPanel;
@property (nonatomic, strong) NSWindow *licencesWindow;

@property (nonatomic, strong) MASShortcutBinder *shortcutBinder;

@end

@implementation JPAppDelegate

static NSString *const CaptureShortcutKey = @"CaptureShortcut";
static NSString *const CaptureShortcutEnabledKey = @"CaptureShortcutEnabled";
static NSString *const CaptureCopyShortcutKey = @"CaptureCopyShortcut";
static NSString *const CaptureCopyShortcutEnabledKey = @"CaptureCopyShortcutEnabled";

static NSString *const UnhyphenateRemoveLineBreaksKey = @"UnhyphenateRemoveLineBreaks";

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self deduplicateRunningInstances];
    
    // Cmd-Shift-8
    MASShortcut *defaultCaptureShortcut = [MASShortcut shortcutWithKeyCode:0x1c modifierFlags:NSCommandKeyMask|NSShiftKeyMask];
    // Cmd-Shift-9
    MASShortcut *defaultCaptureCopyShortcut = [MASShortcut shortcutWithKeyCode:0x19 modifierFlags:NSCommandKeyMask|NSShiftKeyMask];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:@{ CaptureShortcutKey: [NSKeyedArchiver archivedDataWithRootObject:defaultCaptureShortcut], CaptureCopyShortcutKey: [NSKeyedArchiver archivedDataWithRootObject:defaultCaptureCopyShortcut], UnhyphenateRemoveLineBreaksKey: @NO }];

    // Flags that disable the shortcut keys when the menu is hidden so NSMenuItem keyEquivalents work
    self.captureShortcutEnabled = YES;
    self.captureCopyShortcutEnabled = YES;
    
    [self resetShortcutRegistration];
    
    // Observe user preferences to update shortcut menu key equivalent when it changed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:defaults];
    
    [self setupMenuBarItem];
    
    [self initialiseVDKQueue];
    
    // Services
    [NSApp registerServicesMenuSendTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] returnTypes:@[]];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.captureHotkeyView.associatedUserDefaultsKey = CaptureShortcutKey;
    self.captureCopyHotkeyView.associatedUserDefaultsKey = CaptureCopyShortcutKey;
}

#pragma mark - Methods

- (NSString *)appBundleName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
}

- (void)setupMenuBarItem
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.highlightMode = YES;
    
    NSImage *image = [NSImage imageNamed:@"Icon.pdf"];
    image.size = NSMakeSize(14, 14);
    [image setTemplate:YES];
    
    self.statusItem.image = image;
    self.statusItem.menu = self.menu;
    self.statusItem.enabled = YES;
    [self updateMenuWithText:nil];
}

- (void)initialiseVDKQueue
{
    VDKQueue *queue = [[VDKQueue alloc] init];
    [queue addPath:[self screenshotImagesPath] notifyingAbout:VDKQueueEventWrite];
    queue.delegate = self;
}

- (NSString *)screenshotImagesPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportPath = [paths[0] stringByAppendingPathComponent:[self appBundleName]];
    
    BOOL directory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:applicationSupportPath isDirectory:&directory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:applicationSupportPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [paths[0] stringByAppendingPathComponent:[self appBundleName]];
}

- (void)captureScreenArea:(id)sender
{
    NSTask *screencaptureTask = [[NSTask alloc] init];
    [screencaptureTask setLaunchPath:@"/usr/sbin/screencapture"];
    [screencaptureTask setArguments:[NSArray arrayWithObjects:@"-i", [[self screenshotImagesPath] stringByAppendingPathComponent:@"screenshot.png"], nil]];
    [screencaptureTask launch];
}

- (void)captureCopyScreenArea:(id)sender
{
    self.shouldCopy = YES;
    
    [self captureScreenArea:self];
}

- (void)updateMenuWithText:(NSString *)textValue
{
    [self.menu removeAllItems];
    
    NSData *captureData = [[NSUserDefaults standardUserDefaults] dataForKey:CaptureShortcutKey];
    MASShortcut *captureShortcut = [NSKeyedUnarchiver unarchiveObjectWithData:captureData];
    
    NSMenuItem *captureMenuItem = [[NSMenuItem alloc] initWithTitle:@"Capture Screen..." action:@selector(captureScreenArea:) keyEquivalent:(captureShortcut.keyCodeString ?: @"")];
    [captureMenuItem setKeyEquivalentModifierMask:captureShortcut.modifierFlags];
    [self.menu addItem:captureMenuItem];
    
    NSData *captureCopyData = [[NSUserDefaults standardUserDefaults] dataForKey:CaptureCopyShortcutKey];
    MASShortcut *captureCopyShortcut = [NSKeyedUnarchiver unarchiveObjectWithData:captureCopyData];
    
    NSMenuItem *captureCopyMenuItem = [[NSMenuItem alloc] initWithTitle:@"Capture & Copy..." action:@selector(captureCopyScreenArea:) keyEquivalent:(captureCopyShortcut.keyCodeString ?: @"")];
    captureCopyMenuItem.keyEquivalentModifierMask = captureCopyShortcut.modifierFlags;
    [self.menu addItem:captureCopyMenuItem];
    
    if (textValue) {
        [self.menu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *textMenuItem = [[NSMenuItem alloc] initWithTitle:textValue action:nil keyEquivalent:@""];
        
        NSTextView *textView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 0, 190)];
        textView.autoresizingMask = NSViewWidthSizable;
        textView.textContainerInset = NSMakeSize(10, 0);
        textView.enabledTextCheckingTypes = NSTextCheckingAllTypes;
        textView.automaticDataDetectionEnabled = YES;
        textView.backgroundColor = [NSColor clearColor];
        textView.string = textValue;
        [textView checkTextInDocument:nil];
        
        textView.frame = NSMakeRect(0, 0, 1, [NSString heightForString:self.recognizedString font:textView.font width:self.menu.minimumWidth]);
        
        textMenuItem.view = textView;
        
        [textView checkSpelling:self];
        [textView setContinuousSpellCheckingEnabled:YES];
        
        [self.menu addItem:textMenuItem];
        
        [self.menu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *copyMenuItem = [[NSMenuItem alloc] initWithTitle:@"Copy Text" action:@selector(copy:) keyEquivalent:@"c"];
        [self.menu addItem:copyMenuItem];
        
        NSMenu *sharingServiceMenu = [NSSharingServicePicker menuForSharingItems:@[@""] withTarget:self selector:@selector(share:) serviceDelegate:self];
        NSMenuItem *shareMenuItem = [[NSMenuItem alloc] initWithTitle:@"Share" action:nil keyEquivalent:@""];
        [shareMenuItem setSubmenu:sharingServiceMenu];
        [self.menu addItem:shareMenuItem];
        
        NSMenuItem *servicesMenuItem = [[NSMenuItem alloc] initWithTitle:@"Services" action:nil keyEquivalent:@""];
        NSMenu *servicesMenu = [[NSMenu alloc] initWithTitle:@"Services"];
        servicesMenuItem.submenu = servicesMenu;
        [[NSApplication sharedApplication] setServicesMenu:servicesMenu];
        [self.menu addItem:servicesMenuItem];
    }
    
    [self.menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *aboutMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"About %@", [self appBundleName]] action:@selector(showAbout:) keyEquivalent:@""];
    [self.menu addItem:aboutMenuItem];
    
    NSMenuItem *preferencesMenuItem = [[NSMenuItem alloc] initWithTitle:@"Preferences..." action:@selector(showPreferences:) keyEquivalent:@","];
    [self.menu addItem:preferencesMenuItem];
    
    NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Quit %@", [self appBundleName]] action:@selector(quit:) keyEquivalent:@"q"];
    [self.menu addItem:quitMenuItem];
}

- (void)showPreferences:(id)selector
{
    [self.preferencesWindowController showWindow:nil];
    [[NSApplication sharedApplication] arrangeInFront:self];
}

- (void)showAbout:(id)sender
{
    if ([self.modifiedAboutPanel isVisible]) {
        [self.modifiedAboutPanel orderFrontRegardless];
        return;
    }
    
    if (self.modifiedAboutPanel) {
        [self.modifiedAboutPanel makeKeyAndOrderFront:self];
        return;
    }
    
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:self];
    
    // Add a "Credits" button to the About panel and store the resulting panel in the modifiedAboutPanel property
    NSArray *windows = [[NSApplication sharedApplication] windows];
    [windows enumerateObjectsUsingBlock:^(id windowObj, NSUInteger windowIdx, BOOL *windowStop){

        NSArray *subviews = [[(NSWindow *)windowObj contentView] subviews];
        [subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){

            if ([(NSView *)obj isKindOfClass:[NSImageView class]]) {
                if ([[[(NSImageView *)obj image] name] isEqualToString:@"NSApplicationIcon"]) {

                    NSRect frame = [windowObj frame];
                    [windowObj setFrame:NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width, (frame.size.height + 40)) display:NO];

                    NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(82, 20, 120, 70)];
                    button.title = @"Credits...";
                    button.bezelStyle = NSPushOnPushOffButton;
                    button.target = self;
                    button.action = @selector(showLicencesWindow:);

                    [[windowObj contentView] addSubview:button];

                    self.modifiedAboutPanel = windowObj;
                }
            }
        }];
    }];
}

- (void)showLicencesWindow:(id)sender
{
    [self.licencesWindow makeKeyAndOrderFront:NSApp];
    [self.licencesWindow center];
}

- (void)copy:(id)sender
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    
    if (![pasteboard writeObjects:@[self.recognizedString]]) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Unable to copy text";
        alert.informativeText = @"The text was unable to be copied to the pasteboard.";
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
}

- (void)quit:(id)sender
{
    [NSApp terminate:self];
}

- (void)share:(id)sender
{
    NSSharingService *sharingService = [(NSMenuItem *)sender representedObject];
    [sharingService performWithItems:@[self.recognizedString]];
}

- (void)deduplicateRunningInstances
{
    // Based on http://stackoverflow.com/a/3770735/446039
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        
        if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:bundleIdentifier] count] > 1) {
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
                
                NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = [NSString stringWithFormat:@"Another copy of %@ is already running.", [self appBundleName]];
                alert.informativeText = @"To prevent conflicts, this copy will now quit.";
                [alert addButtonWithTitle:@"Quit"];
                [alert runModal];
                [NSApp terminate:nil];
                
            });
        }
    });
}

- (void)processText:(NSString *)string
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:UnhyphenateRemoveLineBreaksKey]) {
        NSError *hyphenationError = nil;
        NSRegularExpression *hyphenationRegex = [NSRegularExpression regularExpressionWithPattern:@"(-|–)\n+([^\n])" options:NSRegularExpressionCaseInsensitive error:&hyphenationError];
        if (!hyphenationError) {
            string = [hyphenationRegex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@"$2"];
        }
        
        NSError *lineBreakError = nil;
        NSRegularExpression *lineBreakRegex = [NSRegularExpression regularExpressionWithPattern:@"([^\n])\n+([^\n])" options:NSRegularExpressionCaseInsensitive error:&lineBreakError];
        if (!lineBreakError) {
            string = [lineBreakRegex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@"$1 $2"];
        }
    }
    self.recognizedString = string;
}

#pragma mark - Getters

- (NSMenu *)menu
{
    if (!_menu) {
        _menu = [[NSMenu alloc] init];
        _menu.minimumWidth = 300;
        _menu.delegate = self;
    }
    return _menu;
}

- (NSWindowController *)preferencesWindowController
{
    if (!_preferencesWindowController) {
        NSViewController *generalViewController = [[GeneralPreferencesViewController alloc] init];
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:@[generalViewController] title:@"Preferences"];
    }
    return _preferencesWindowController;
}

- (NSWindow *)licencesWindow
{
    if (!_licencesWindow) {
        _licencesWindow = [[JPLicencesWindow alloc] init];
    }
    return _licencesWindow;
}

- (MASShortcutBinder *)shortcutBinder {
    if (!_shortcutBinder) {
        _shortcutBinder = [[MASShortcutBinder alloc] init];
    }
    return _shortcutBinder;
}


#pragma mark - Setters

- (void)setRecognizedString:(NSString *)recognizedString
{
    if (![_recognizedString isEqualToString:recognizedString]) {
        _recognizedString = [recognizedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    return;
}

#pragma mark - Services

- (id)validRequestorForSendType:(NSString *)sendType returnType:(NSString *)returnType
{
    if ([sendType isEqual:NSStringPboardType]) {
        return self;
    }
    return nil;
}

- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pasteboard types:(NSArray *)types
{
    NSArray *typesDeclared;
    
    if ([types containsObject:NSStringPboardType] == NO) {
        return NO;
    }
    typesDeclared = [NSArray arrayWithObject:NSStringPboardType];
    [pasteboard declareTypes:typesDeclared owner:nil];
    
    return [pasteboard setString:self.recognizedString forType:NSStringPboardType];
}

#pragma mark - Queue delegate
- (void)queue:(VDKQueue *)queue didReceiveNotification:(NSString *)notificationName forPath:(NSString *)fpath
{
    // The /usr/sbin/screencapture utility on OS X works by creating a file in the directory in the form of ".screenshot.png-kVux" (or, when sandboxed, "screenshot.png.sb-ef997bf5-gyNNMv") as it writes data to the file, this file is then renamed to "screenshot.png" as we originally requested – in order to prevent the menu from popping up twice, we ignore the VDKQueue notification that's generated by the temporary file being writted to [self screenshotImagesPath]

    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fpath error:nil];
    NSPredicate *temporaryFilesPredicate = [NSPredicate predicateWithFormat:@"(self BEGINSWITH '.') OR (self MATCHES 'screenshot\\.png\\.sb-.+')"];
    NSArray *temporaryFiles = [directoryContents filteredArrayUsingPredicate:temporaryFilesPredicate];
    if ([temporaryFiles count] != 0) {
        return;
    }
    
    NSString *imagePath = [[self screenshotImagesPath] stringByAppendingPathComponent:@"screenshot.png"];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
    
    JPImageRecognizer *imageRecognizer = [[JPImageRecognizer alloc] init];
    NSString *recognizedText = [imageRecognizer recognizeImage:image];
    
    if (recognizedText) {
        [self processText:recognizedText];
        [self updateMenuWithText:self.recognizedString];
        
        if (self.shouldCopy) {
            [self copy:self];
            self.shouldCopy = NO;
        }
        else {
            [self.statusItem popUpStatusItemMenu:self.menu];
        }
        
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
    }
}

#pragma mark - Custom shortcut

- (void)resetShortcutRegistration {
    if (self.captureShortcutEnabled) {
        [self.shortcutBinder bindShortcutWithDefaultsKey:CaptureShortcutKey toAction:^{
            [self.menu cancelTracking];
            [self captureScreenArea:self];
        }];
    }
    else {
        [self.shortcutBinder breakBindingWithDefaultsKey:CaptureShortcutKey];
    }
    
    if (self.captureCopyShortcutEnabled) {
        [self.shortcutBinder bindShortcutWithDefaultsKey:CaptureCopyShortcutKey toAction:^{
            [self.menu cancelTracking];
            [self captureCopyScreenArea:self];
        }];
    }
    else {
        [self.shortcutBinder breakBindingWithDefaultsKey:CaptureCopyShortcutKey];
    }
}

#pragma mark - User defaults observing

- (void)userDefaultsDidChange:(NSNotification *)note
{
    [self updateMenuWithText:self.recognizedString];
}

#pragma mark - Menu delegate

// Need to prevent the global hotkey registration to allow the NSMenuItem keyEquivalent's to function

- (void)menuWillOpen:(NSMenu *)menu
{
    self.captureShortcutEnabled = NO;
    self.captureCopyShortcutEnabled = NO;
    
    [self resetShortcutRegistration];
}

- (void)menuDidClose:(NSMenu *)menu
{
    self.captureShortcutEnabled = YES;
    self.captureCopyShortcutEnabled = YES;
    
    [self resetShortcutRegistration];
}

@end
