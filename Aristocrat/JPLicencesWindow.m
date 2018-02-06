//
//  JPLicencesWindow.m
//  Aristocrat
//
//  Created by Josh Parnham on 20/2/17.
//  Copyright © 2017 Josh Parnham. All rights reserved.
//

#import "JPLicencesWindow.h"

@implementation JPLicencesWindow

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:style backing:bufferingType defer:flag];
    if (self) {
        self = (JPLicencesWindow *)[[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 600, 600) styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable) backing:NSBackingStoreBuffered defer:NO];
        self.releasedWhenClosed = NO;
        
        // Based on https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/TextUILayer/Tasks/TextInScrollView.html
        
        NSScrollView *scrollview = [[NSScrollView alloc] initWithFrame:((NSClipView *)self.contentView).bounds];
        NSSize contentSize = [scrollview contentSize];
        
        scrollview.borderType = NSNoBorder;
        scrollview.hasVerticalScroller = YES;
        scrollview.hasHorizontalScroller = NO;
        scrollview.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable);
        
        NSTextView *textView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)];
        textView.minSize = NSMakeSize(0.0, contentSize.height);
        textView.maxSize = NSMakeSize(FLT_MAX, FLT_MAX);
        textView.verticallyResizable = YES;
        textView.horizontallyResizable = NO;
        textView.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable);
        
        NSString *rtfFilePath = [[NSBundle mainBundle] pathForResource:@"Licences" ofType:@"rtf"];
        [textView readRTFDFromFile:rtfFilePath];
        
        textView.textContainer.widthTracksTextView = YES;
        scrollview.documentView = textView;
        textView.textContainer.containerSize = NSMakeSize(FLT_MAX, FLT_MAX);
        
        self.contentView = scrollview;
    }
    return self;
}

@end
