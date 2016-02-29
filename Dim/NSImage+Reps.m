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
    NSArray *reps = [self representations];
    for (NSBitmapImageRep *imgRep in reps) {
        
//        NSLog(@"----------------");
//        NSLog([imgRep description]);
        
        if (scale == 1.0 && imgRep.pixelsWide == width) {
            return imgRep;
        }
        if (scale == 2.0 && imgRep.pixelsWide == width * 2) {
            return imgRep;
        }
//        if (imgRep.size.width == width) {
//            if (imgRep.pixelsWide == width * scale) {
//                return imgRep;
//            }
//        }
    }
    return nil;
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
