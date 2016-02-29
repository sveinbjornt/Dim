//
//  DIMIconView.m
//  DocumentIconMaker
//
//  Created by Sveinbjorn Thordarson on 06/02/16.
//  Copyright © 2016 Sveinbjorn Thordarson. All rights reserved.
//

#import "DimIconView.h"

@interface DimIconView ()

@end

@implementation DimIconView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if ((self = [super initWithFrame:frameRect])) {
//        CALayer *viewLayer = [CALayer layer];
//        [viewLayer setBackgroundColor:CGColorCreateGenericRGB(0.0, 0.0, 1.0, 1.0)];
//        [self setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
//        [self setLayer:viewLayer];
        _overlayRect = frameRect;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[self srcImage] drawInRect:[self bounds]
                       fromRect:[self bounds]
                      operation:NSCompositeCopy
                       fraction:1.0
                 respectFlipped:YES
                          hints:nil];
    
    [[self overlayImage] drawInRect:_overlayRect
                       fromRect:[self bounds]
                      operation:NSCompositeSourceOver
                       fraction:1.0
                 respectFlipped:YES
                          hints:nil];

}

- (void)sliderChanged:(id)sender {
    float proportion = [sender intValue] / [sender maxValue];
    NSRect rect = NSMakeRect(0, 0, self.bounds.size.width * proportion, self.bounds.size.height * proportion);
    _overlayRect = rect;
    _overlayRect = [self centerRect:_overlayRect inRect:[self bounds]];
    [self setNeedsDisplay:YES];
}

- (NSRect) centerRect: (NSRect) smallRect
               inRect: (NSRect) bigRect
{
    NSRect centerRect;
    centerRect.size = smallRect.size;
    
    centerRect.origin.x = (bigRect.size.width - smallRect.size.width) / 2.0;
    centerRect.origin.y = (bigRect.size.height - smallRect.size.height) / 2.0;
    
    return (centerRect);
    
} // centerRect

- (BOOL)isFlipped {
    return YES;
}

@end
