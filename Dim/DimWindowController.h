//
//  DIMWindowController.h
//  DocumentIconMaker
//
//  Created by Sveinbjorn Thordarson on 06/02/16.
//  Copyright © 2016 Sveinbjorn Thordarson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DimWindowController : NSWindowController

@property (retain, readonly) NSImage *docImage;
@property (retain, readonly) NSImage *overlayImage;

- (IBAction)restoreDefaultIcon:(id)sender;
- (IBAction)copyIcon:(id)sender;
- (IBAction)selectIcon:(id)sender;

- (BOOL)loadOverlayIcon:(NSString *)overlayIconPath;

@end
