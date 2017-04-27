//
//  DimComposition.h
//  Dim
//
//  Created by Sveinbjorn Thordarson on 18/04/2017.
//  Copyright © 2017 Sveinbjorn Thordarson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface DimComposition : NSObject

@property (assign, nonatomic) NSImage *baseImage;
@property (assign, nonatomic) NSImage *overlayImage;

@property BOOL forceAllResolutions;
@property CGFloat overlaySize;
@property CGFloat overlayXOffset;
@property CGFloat overlayYOffset;
@property CGFloat overlayOpacity;

@property CGFloat labelFontSize;
@property (assign, nonatomic) NSFont *labelFont;
@property (assign, nonatomic) NSColor *labelColor;

- (instancetype)initWithBaseImage:(NSImage *)base overlayImage:(NSImage *)overlay;

- (CGImageRef)newCGImageForSize:(NSSize)size scale:(CGFloat)scale;
- (void)drawSize:(NSSize)size scale:(CGFloat)scale inContext:(CGContextRef)context;

- (BOOL)createIconSetAtPath:(NSString *)path;

@end
