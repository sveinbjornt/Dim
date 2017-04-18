//
//  NSImage+Reps.h
//  Dim
//
//  Created by Sveinbjorn Thordarson on 27/02/16.
//  Copyright © 2016 Sveinbjorn Thordarson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Reps)

- (NSBitmapImageRep *)representationForSize:(CGFloat)width scale:(CGFloat)scale;
- (void)printRepresentations;

@end
