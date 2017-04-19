//
//  NSImage+Reps.m
//  Dim
//
//  Created by Sveinbjorn Thordarson on 27/02/16.
//  Copyright © 2016 Sveinbjorn Thordarson. All rights reserved.
//

#import "NSImage+Reps.h"

@implementation NSImage (Reps)

- (NSBitmapImageRep *)representationForSize:(CGFloat)width scale:(CGFloat)scale {
    for (NSBitmapImageRep *imgRep in [self representations]) {
        
        CGFloat repScale = imgRep.pixelsWide / imgRep.size.width;
        
        if (repScale == scale && (imgRep.pixelsWide / repScale) == width) {
            return imgRep;
        }
    }
    return nil;
}

- (NSBitmapImageRep *)bestRepresentationForSize:(CGFloat)width scale:(CGFloat)scale {
    NSBitmapImageRep *rep = [self representationForSize:width scale:scale];
    if (rep == nil) {
        
        // Try to get a higher scale version
        if (scale == 1.0) {
            rep = [self representationForSize:width/2 scale:2.0];
            if (rep) {
                return rep;
            }
            rep = [self representationForSize:width scale:2.0];
            if (rep) {
                return rep;
            }
            rep = [self representationForSize:width*2 scale:1.0];
            if (rep) {
                return rep;
            }
            rep = [self representationForSize:width*2 scale:2.0];
            if (rep) {
                return rep;
            }
            rep = [self representationForSize:width*4 scale:1.0];
            if (rep) {
                return rep;
            }
            rep = [self representationForSize:width/2 scale:1.0];
            if (rep) {
                return rep;
            }
            rep = [self representationForSize:width/2 scale:2.0];
            if (rep) {
                return rep;
            }
            rep = [self representationForSize:width/4 scale:1.0];
            if (rep) {
                return rep;
            }
        }
        // Try to find lower scale version of larger image
        if (scale == 2.0) {
            rep = [self representationForSize:width*2 scale:1.0];
            if (rep) {
                return rep;
            }
            rep = [self representationForSize:width*2 scale:2.0];
            if (rep) {
                return rep;
            }
            rep = [self representationForSize:width*4 scale:1.0];
            if (rep) {
                return rep;
            }
            // OK, at this point we'll have to start looking for
            // lower resolution representations to scale up
            rep = [self representationForSize:width scale:1.0];
            if (rep) {
                return rep;
            }
            rep = [self representationForSize:width/2 scale:2.0];
            if (rep) {
                return rep;
            }
            rep = [self representationForSize:width/2 scale:1.0];
            if (rep) {
                return rep;
            }
            rep = [self representationForSize:width/4 scale:1.0];
            if (rep) {
                return rep;
            }
        }
        
        
    }
    return rep;
}

- (void)printRepresentations {
    NSArray *reps = [self representations];
    for (NSBitmapImageRep *imgRep in reps) {
        CGFloat scale = [imgRep pixelsWide] / imgRep.size.width;
        NSString *ss = scale == 1.0f ? @"" : [NSString stringWithFormat:@"(@%.0fx)", scale];
        NSLog(@"%.0f x %.0f %@", [imgRep pixelsWide] / scale, [imgRep pixelsHigh] / scale, ss);
    }
}

@end
