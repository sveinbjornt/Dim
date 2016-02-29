//
//  DIMIconView.h
//  DocumentIconMaker
//
//  Created by Sveinbjorn Thordarson on 06/02/16.
//  Copyright © 2016 Sveinbjorn Thordarson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DimIconView : NSView

@property NSBitmapImageRep *srcImage;
@property NSBitmapImageRep *overlayImage;
@property NSRect overlayRect;

- (void)sliderChanged:(id)sender;

@end
