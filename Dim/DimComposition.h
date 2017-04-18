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

- (instancetype)initWithBaseImage:(NSImage *)base overlayImage:(NSImage *)overlay;
- (BOOL)createIconSetAtPath:(NSString *)path;
- (BOOL)createIcnsAtPath:(NSString *)path;

@end
