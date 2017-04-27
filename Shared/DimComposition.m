//
//  DimComposition.m
//  Dim
//
//  Created by Sveinbjorn Thordarson on 18/04/2017.
//  Copyright © 2017 Sveinbjorn Thordarson. All rights reserved.
//

#import "DimComposition.h"
#import "NSImage+Reps.h"
#import "Common.h"

static BOOL CGImageWriteToFile(CGImageRef image, NSString *path, NSString *imageUTType) {
    
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, (CFStringRef)imageUTType, 1, NULL);
    if (!destination) {
        NSLog(@"Failed to create CGImageDestination for %@", path);
        return NO;
    }
    
    CGImageDestinationAddImage(destination, image, nil);
    
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"Failed to write image to %@", path);
        CFRelease(destination);
        return NO;
    }
    
    CFRelease(destination);
    return YES;
}

static NSRect CenterNSRectInNSRect(NSRect smallRect, NSRect bigRect) {
    NSRect centerRect;
    centerRect.size = smallRect.size;
    
    centerRect.origin.x = (bigRect.size.width - smallRect.size.width) / 2.0;
    centerRect.origin.y = (bigRect.size.height - smallRect.size.height) / 2.0;
    
    return centerRect;
}

#pragma mark -

@interface DimComposition()
{

}
@end

@implementation DimComposition

- (instancetype)initWithBaseImage:(NSImage *)base overlayImage:(NSImage *)overlay {
    if ((self = [super init])) {
        _baseImage = base;
        _overlayImage = overlay;
        _overlaySize = DEFAULT_OVERLAY_SIZE;
        _overlayXOffset = DEFAULT_OVERLAY_XOFFSET;
        _overlayYOffset = DEFAULT_OVERLAY_YOFFSET;
        _overlayOpacity = DEFAULT_OVERLAY_OPACITY;
    }
    return self;
}

#pragma mark -

- (BOOL)createIconSetAtPath:(NSString *)destinationPath {
    
    // Create destination iconset folder if it doesn't exist
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:destinationPath] == NO) {
        
        [fm createDirectoryAtPath:destinationPath
      withIntermediateDirectories:YES
                       attributes:nil
                            error:nil];
        
        if (![fm fileExistsAtPath:destinationPath]) {
            NSLog(@"Unable to create output directory");
            return NO;
        }
    }
    
    // Create each rep in turn
    for (NSImageRep *rep in [self.baseImage representations]) {
        if (![rep isKindOfClass:[NSBitmapImageRep class]]) {
            continue;
        }
        
        NSBitmapImageRep *r = (NSBitmapImageRep *)rep;
        NSSize size = [r size];
        CGFloat scale = [r pixelsWide] / size.width;
        
        NSString *scaleStr = (scale == 1.0f) ? @"" : [NSString stringWithFormat:@"@%dx", (int)scale];
        NSString *identifier = [NSString stringWithFormat:@"%dx%d%@",
                                (int)size.width, (int)size.height, scaleStr];
        
        NSString *baseName = @"icon";
        NSString *outPath = [NSString stringWithFormat:@"%@/%@_%@.png", destinationPath, baseName, identifier];
        NSLog(@"Generating %@", outPath);
        
        CGImageRef img = [self newCGImageForSize:size scale:scale];
        CGImageWriteToFile(img, outPath, (NSString *)kUTTypePNG);
        CGImageRelease(img);
    }
    
    return YES;
}

- (CGImageRef)newCGImageForSize:(NSSize)size scale:(CGFloat)scale {
    // Create a bitmap graphics context of the given size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 size.width * scale,
                                                 size.height * scale,
                                                 8,
                                                 0,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    // draw icon
    [self drawSize:size scale:scale inContext:context];
    
    // Get image from context
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return cgImage;
}

- (void)drawSize:(NSSize)size scale:(CGFloat)scale inContext:(CGContextRef)context {
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    NSBitmapImageRep *baseRep = [self.baseImage bestRepresentationForSize:width scale:scale];
    NSBitmapImageRep *overRep = [self.overlayImage bestRepresentationForSize:width scale:scale];
    
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    CGContextSetRGBFillColor(context, (CGFloat)0.0, (CGFloat)0.0, (CGFloat)0.0, (CGFloat)0.0);
    
    CGFloat overlayPropSize = self.overlaySize;
    NSRect docRect = NSMakeRect(0, 0, width * scale, height * scale);
    
    // Scale down dest rect
    NSRect overlaySizeRect = NSMakeRect(0, 0, overlayPropSize * docRect.size.width, overlayPropSize * docRect.size.height);
    NSRect dstRect = CenterNSRectInNSRect(overlaySizeRect, docRect);
    
    // Adjust according to x and y offsets
    NSInteger unit = docRect.size.width / 2;
    dstRect.origin.x += ((self.overlayXOffset/100.f) * unit);
    dstRect.origin.y += ((self.overlayYOffset/100.f) * unit);
    
    // Draw images
    CGContextDrawImage(context, docRect, baseRep.CGImage);
    
    CGContextSetAlpha(context, self.overlayOpacity);
    CGContextDrawImage(context, dstRect, overRep.CGImage);
    CGContextSetAlpha(context, 1.0f);
}

@end
