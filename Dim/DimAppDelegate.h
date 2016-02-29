//
//  AppDelegate.h
//  DocumentIconMaker
//
//  Created by Sveinbjorn Thordarson on 06/02/16.
//  Copyright © 2016 Sveinbjorn Thordarson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DimWindowController.h"

@interface DimAppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet DimWindowController *windowController;

@end

