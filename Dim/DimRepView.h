//
//  DIMRepView.h
//  DocumentIconMaker
//
//  Created by Sveinbjorn Thordarson on 26/02/16.
//  Copyright © 2016 Sveinbjorn Thordarson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DimRepView : NSView

@property (nonatomic) CGFloat scale;
@property NSSize actualSize;

- (void)aspectFit;
- (void)fitToActualSize;

@end
