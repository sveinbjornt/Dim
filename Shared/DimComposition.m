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
    
    return (centerRect);
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
        _overlaySize = DEFAULT_OVERLAY_SIZE;
        _overlayXOffset = 0.f;
        _overlayYOffset = 0.f;
        
        if (baseImage == nil || overlayImage == nil) {
            return nil;
        }
    }
    return self;
}

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
    
    NSLog(@"Creating at %@", destinationPath);

    // Create each rep in turn
    for (NSImageRep *rep in [baseImage representations]) {
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
        
        CGImageRef img = [self newImageForSize:size scale:scale];
        CGImageWriteToFile(img, outPath, (NSString *)kUTTypePNG);
        CGImageRelease(img);
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
    
    CGContextSetRGBFillColor(context, (CGFloat)0.0, (CGFloat)0.0, (CGFloat)0.0, (CGFloat)0.0);
    
    CGFloat overlayPropSize = self.overlaySize;
    NSRect docRect = NSMakeRect(0, 0, width * scale, height * scale);
    
    // Scale down dest rect
    NSRect overlaySizeRect = NSMakeRect(0, 0, overlayPropSize * docRect.size.width, overlayPropSize * docRect.size.height);
    NSRect dstRect = CenterNSRectInNSRect(overlaySizeRect, docRect);

    // Draw images
    CGContextDrawImage(context, docRect, baseRep.CGImage);
    CGContextDrawImage(context, dstRect, overRep.CGImage);

    // Get image from context
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return cgImage;
}

- (BOOL)createIcnsAtPath:(NSString *)path {
    return YES;
}

+ (BOOL)convertIconSet:(NSString *)iconsetPath toIcns:(NSString *)outputIcnsPath {
    NSString *iconutilPath = ICONUTIL_PATH;
    if (![[NSFileManager defaultManager] fileExistsAtPath:iconutilPath]) {
        NSLog(@"%@ not installed on this system", iconutilPath);
        return NO;
    }
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = iconutilPath;
    task.arguments = @[@"--convert", @"icns", @"--output", outputIcnsPath, iconsetPath];
    task.standardOutput = [NSFileHandle fileHandleWithNullDevice];
    task.standardError = [NSFileHandle fileHandleWithNullDevice];
    [task launch];
    [task waitUntilExit];
    
    return YES;
}

@end