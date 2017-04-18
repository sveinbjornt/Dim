//
//  DimComposition.m
//  Dim
//
//  Created by Sveinbjorn Thordarson on 18/04/2017.
//  Copyright © 2017 Sveinbjorn Thordarson. All rights reserved.
//

#import "DimComposition.h"
#import <AppKit/AppKit.h>
#import "NSImage+Reps.h"

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

#pragma mark -

@interface DimComposition()
{
    NSImage *baseImage;
    NSImage *overlayImage;
}
@end

@implementation DimComposition

- (instancetype)initWithBaseImage:(NSImage *)base overlayImage:(NSImage *)overlay {
    if ((self = [super init])) {
        baseImage = base;
        overlayImage = overlay;
        if (baseImage == nil || overlayImage == nil) {
            return nil;
        }
    }
    return self;
}

- (BOOL)createIconSetAtPath:(NSString *)destinationPath {
//    NSMutableDictionary *images = [NSMutableDictionary dictionary];
    
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
    
    
    
    
    NSLog(@"Creating at %@", destinationPath);

    // Create each rep in turn
    for (NSImageRep *rep in [baseImage representations]) {
        if (![rep isKindOfClass:[NSBitmapImageRep class]]) {
            continue;
        }
        
        NSBitmapImageRep *r = (NSBitmapImageRep *)rep;
        NSSize size = [r size];
        CGFloat scale = [r pixelsWide] / size.width;
        
        NSString *identifier = [NSString stringWithFormat:@"%dx%d@%dx",
                                (int)size.width, (int)size.height, (int)scale];
        
        NSString *outPath = [NSString stringWithFormat:@"%@/%@.png", destinationPath, identifier];
        NSLog(@"Generating %@", outPath);
        
        CGImageRef img = [self newImageForSize:size scale:scale];
        CGImageWriteToFile(img, outPath, (NSString *)kUTTypePNG);
    }
    
    
    return YES;
}

- (CGImageRef)newImageForSize:(NSSize)size scale:(CGFloat)scale {
    CGFloat width = size.width;
    CGFloat height = size.height;

    NSBitmapImageRep *baseRep = [baseImage representationForSize:width scale:scale];
    NSBitmapImageRep *overRep = [overlayImage representationForSize:width scale:scale];
    
    // Create a bitmap graphics context of the given size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 width * scale,
                                                 height * scale,
                                                 8,
                                                 0,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    
    
    // Draw ...
    CGContextSetRGBFillColor(context, (CGFloat)0.0, (CGFloat)0.0, (CGFloat)0.0, (CGFloat)0.0);
    
    NSRect destRect = NSMakeRect(0, 0, width * scale, height * scale);
    
    CGContextDrawImage(context, destRect, baseRep.CGImage);
    CGContextDrawImage(context, destRect, overRep.CGImage);

    // Get image from context
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    
    return cgImage;
}

- (BOOL)createIcnsAtPath:(NSString *)path {
    return YES;
}

@end
