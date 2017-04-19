//
//  DimComposition.h
//  Dim
//
//  Created by Sveinbjorn Thordarson on 18/04/2017.
//  Copyright © 2017 Sveinbjorn Thordarson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DimComposition : NSObject

@property BOOL forceAllResolutions;
@property CGFloat overlaySize;
@property CGFloat overlayXOffset;
@property CGFloat overlayYOffset;
@property CGFloat overlayOpacity;

- (instancetype)initWithBaseImage:(NSImage *)base overlayImage:(NSImage *)overlay;
- (BOOL)createIconSetAtPath:(NSString *)path;
- (BOOL)createIcnsAtPath:(NSString *)path;

+ (BOOL)convertIconSet:(NSString *)iconsetPath toIcns:(NSString *)outputIcnsPath;

@end
