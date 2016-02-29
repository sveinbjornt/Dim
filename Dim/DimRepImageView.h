//
//  DimCombinedImageView.h
//  Dim
//
//  Created by Sveinbjorn Thordarson on 26/02/16.
//  Copyright © 2016 Sveinbjorn Thordarson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DimRepImageView : NSView

@property CGFloat size;
@property BOOL at2x;

@property (retain, nonatomic) NSBitmapImageRep *docImgRep;
@property (retain, nonatomic) NSBitmapImageRep *overlayImgRep;

@property BOOL drawBackground;

@end
