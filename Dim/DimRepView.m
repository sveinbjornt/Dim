//
//  DIMRepView.m
//  DocumentIconMaker
//
//  Created by Sveinbjorn Thordarson on 26/02/16.
//  Copyright © 2016 Sveinbjorn Thordarson. All rights reserved.
//

#import "DimRepView.h"
#import "Common.h"
#import "DimRepImageView.h"

NSRect CenterNSRectInNSRect(NSRect smallRect, NSRect bigRect) {
    NSRect centerRect;
    centerRect.size = smallRect.size;
    
    centerRect.origin.x = (bigRect.size.width - smallRect.size.width) / 2.0;
    centerRect.origin.y = (bigRect.size.height - smallRect.size.height) / 2.0;
    
    return (centerRect);
    
}

CGFloat ScaleToAspectFitRectInRect(CGRect rfit, CGRect rtarget)
{
    // first try to match width
    CGFloat s = CGRectGetWidth(rtarget) / CGRectGetWidth(rfit);
    // if we scale the height to make the widths equal, does it still fit?
    if (CGRectGetHeight(rfit) * s <= CGRectGetHeight(rtarget)) {
        return s;
    }
    // no, match height instead
    return CGRectGetHeight(rtarget) / CGRectGetHeight(rfit);
}


CGRect AspectFitRectInRect(CGRect rfit, CGRect rtarget)
{
    CGFloat s = ScaleToAspectFitRectInRect(rfit, rtarget);
    CGFloat w = CGRectGetWidth(rfit) * s;
    CGFloat h = CGRectGetHeight(rfit) * s;
    CGFloat x = CGRectGetMidX(rtarget) - w / 2;
    CGFloat y = CGRectGetMidY(rtarget) - h / 2;
    return CGRectMake(x, y, w, h);
}



@interface DimRepView ()

@property (weak) IBOutlet DimRepImageView *imgView;
@property (retain) NSColor *bgColor;

@end

@implementation DimRepView

- (void)awakeFromNib {
    self.scale = 1.0;
    self.bgColor = [NSUnarchiver unarchiveObjectWithData:[DEFAULTS objectForKey:@"RepresentationBackgroundColor"]];
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                              forKeyPath:@"values.RepresentationBackgroundColor"
                                                                 options:NSKeyValueObservingOptionNew
                                                                 context:NULL];
}

- (void)aspectFit {
//    CGRect img = NSRectToCGRect(self.imgView.frame);
//    CGRect frame = NSRectToCGRect(self.frame);
//    
//    NSRect newImgFrame = NSRectFromCGRect(AspectFitRectInRect(img, frame));
    [self.imgView setFrame:self.bounds];
}

- (void)fitToActualSize {
    self.scale = 1.0;
    [self updateFrame];
}

- (void)setScale:(CGFloat)scale {
    _scale = scale;
    [self updateFrame];
}

//- (CGFloat)scale {
//    return _scale;
//}


- (void)updateFrame {
    [self.imgView setFrame:CenterNSRectInNSRect(self.imgView.frame, self.bounds)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.bgColor = [NSUnarchiver unarchiveObjectWithData:[DEFAULTS objectForKey:@"RepresentationBackgroundColor"]];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    // set any NSColor for filling, say white:
    [self.bgColor setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

@end
