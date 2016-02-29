//
//  AppDelegate.m
//  DocumentIconMaker
//
//  Created by Sveinbjorn Thordarson on 06/02/16.
//  Copyright © 2016 Sveinbjorn Thordarson. All rights reserved.
//

#import "DimAppDelegate.h"

@interface DimAppDelegate ()

@end

@implementation DimAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
    [self.windowController loadOverlayIcon:filename];
    return YES;
}

@end
