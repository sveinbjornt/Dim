//
//  DimCombinedImageView.m
//  Dim
//
//  Created by Sveinbjorn Thordarson on 26/02/16.
//  Copyright © 2016 Sveinbjorn Thordarson. All rights reserved.
//

#import "DimRepImageView.h"
#import "Common.h"

@implementation DimRepImageView

- (instancetype)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {

        [self setWantsLayer:YES];
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [NSColor grayColor].CGColor;
        self.layer.masksToBounds = YES;
        
        for (NSString *key in @[@"LabelsEnabled",
                                @"LabelColor",
                                @"LabelFont",
                                @"LabelFontSizePercentage",
                                @"LabelXOffset",
                                @"LabelYOffset",
                                @"CurrentLabel",
                                @"DocumentIconEnabled",
                                @"OverlayIconEnabled",
                                @"OverlaySize",
                                @"OverlayXOffset",
                                @"OverlayYOffset",
                                @"RepresentationBackgroundColor",
                                @"DrawBorder"])
        {
            NSString *keyPath = [NSString stringWithFormat:@"values.%@", key];
            [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                                      forKeyPath:keyPath
                                                                         options:NSKeyValueObservingOptionNew
                                                                         context:NULL];
        }
        
        
    }
    return self;
}

#pragma mark - Key/Value observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self setNeedsDisplay:YES];
//    [self scaleUnitSquareToSize:NSMakeSize(0.9, 0.9)];
}

#pragma mark -

- (void)drawRect:(NSRect)dirtyRect {
    
    // Draw background
    if (self.drawBackground) {
        NSColor *bgColor = [NSUnarchiver unarchiveObjectWithData:[DEFAULTS objectForKey:@"RepresentationBackgroundColor"]];
        [bgColor setFill];
        NSRectFill(dirtyRect);
    }
    
    CGFloat size = self.docImgRep.size.width;
    
    NSRect docRect = NSMakeRect(0, 0, size, size);
    docRect = [self convertRectFromBacking:docRect];
    NSLog(NSStringFromRect(docRect));
    
    // Draw document icon
    if ([DEFAULTS boolForKey:@"DocumentIconEnabled"] && self.docImgRep) {
    
        [self.docImgRep drawInRect:docRect
                          fromRect:NSZeroRect
                         operation:NSCompositeSourceOver
                          fraction:1.0
                    respectFlipped:YES
                             hints:nil];
    }
    
    // Draw overlay icon
    if ([DEFAULTS boolForKey:@"OverlayIconEnabled"] && self.overlayImgRep) {

        // Get settings from defaults
        CGFloat overlayPropSize = [DEFAULTS integerForKey:@"OverlaySize"] / 100.f;
        CGFloat xOffsetPercentage = [DEFAULTS integerForKey:@"OverlayXOffset"];
        CGFloat yOffsetPercentage = [DEFAULTS integerForKey:@"OverlayYOffset"];
        
        // Src rect is always size of bitmap
//        NSRect srcRect = NSMakeRect(0, 0, [self.overlayImgRep pixelsWide], [self.overlayImgRep pixelsHigh]);
        
        // Scale down dest rect
        NSRect dstRect = NSMakeRect(0, 0, overlayPropSize * docRect.size.width, overlayPropSize * docRect.size.height);
        
        // Adjust acc. to x and y offsets
        CGFloat x = (self.bounds.size.width / 2);
        x *= ((xOffsetPercentage * 2) / 100.f);
        CGFloat y = (self.bounds.size.height / 2);
        y *= ((yOffsetPercentage * 2) / 100.f);

        CGFloat w = dstRect.size.width;
        CGFloat h = dstRect.size.height;
        dstRect = NSMakeRect(x - (w/2), y - (h/2), dstRect.size.width, dstRect.size.height);

        // Draw it
        NSInteger interpolation = [DEFAULTS integerForKey:@"DrawBorder"] ? NSImageInterpolationHigh : NSImageInterpolationNone;
        [self.overlayImgRep drawInRect:dstRect
                              fromRect:NSZeroRect
                             operation:NSCompositeSourceOver
                              fraction:1.0
                        respectFlipped:YES
                                 hints:@{ NSImageHintInterpolation: @(interpolation) }];
    }
    
    // Draw label
    if ([DEFAULTS boolForKey:@"LabelsEnabled"] && [DEFAULTS objectForKey:@"CurrentLabel"]) {
        
        NSString *fontName = [DEFAULTS objectForKey:@"LabelFont"];
        CGFloat fontScale = [DEFAULTS integerForKey:@"LabelFontSizePercentage"] / 100.f;
        CGFloat fontSize = (int)([self fontSize] * fontScale);
        NSFont *font = [NSFont fontWithName:fontName size:fontSize];
        
        NSColor *color = DEFAULT_LABEL_COLOR;
        if ([DEFAULTS objectForKey:@"LabelColor"]) {
            color = [NSUnarchiver unarchiveObjectWithData:[DEFAULTS objectForKey:@"LabelColor"]];
        }
        
        NSDictionary *attributes = @{
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color
        };

        NSString *currentLabelString = [DEFAULTS objectForKey:@"CurrentLabel"];
        NSAttributedString *label = [[NSAttributedString alloc] initWithString:currentLabelString
                                                                    attributes:attributes];
        NSSize labelSize = [label size];

        CGFloat xoffsetProp = [DEFAULTS integerForKey:@"LabelXOffset"] / 50.f;
        CGFloat xoffset = ((self.bounds.size.width - labelSize.width) / 2) * xoffsetProp;

        CGFloat yoffsetProp = [DEFAULTS integerForKey:@"LabelYOffset"] / 50.f;
        CGFloat yoffset = ([self labelYPos]) * yoffsetProp;
        
        [label drawAtPoint:NSMakePoint(xoffset, yoffset)];
    }
}

- (CGFloat)fontSize {
    
    switch ((int)self.docImgRep.size.width) {
        case 512:
            return 72.f;
            break;
        case 256:
            return 38.f;
            break;
        case 128:
            return 18.f;
            break;
        case 32:
            return 7.f;
        case 16:
            return 4.f;
            break;
    }
    NSLog(@"Font size not found for size %d", (int)self.docImgRep.size.width);
    
    return 0.f;
}

- (CGFloat)labelYPos {
    
    switch ((int)self.docImgRep.size.width) {
        case 512:
            return 72.f;
            break;
        case 256:
            return 38.f;
            break;
        case 128:
            return 20;
            break;
        case 32:
            return 3.f;
        case 16:
            return 1.f;
            break;
    }
    NSLog(@"Label Y pos not found for size %d", (int)self.docImgRep.size.width);
    
    return 0.f;
}

- (NSRect)centerRect:(NSRect)smallRect inRect:(NSRect)bigRect
{
    NSRect centerRect;
    centerRect.size = smallRect.size;
    
    centerRect.origin.x = (bigRect.size.width - smallRect.size.width) / 2.0;
    centerRect.origin.y = (bigRect.size.height - smallRect.size.height) / 2.0;
    
    return (centerRect);
}

@end
