//
//  DIMRepresentationsViewController.m
//  DocumentIconMaker
//
//  Created by Sveinbjorn Thordarson on 25/02/16.
//  Copyright © 2016 Sveinbjorn Thordarson. All rights reserved.
//

#import "DimRepresentationsViewController.h"
#import <Cocoa/Cocoa.h>
#import "Common.h"
#import "DimRepView.h"
#import "DimWindowController.h"
#import "DimRepImageView.h"
#import "NSImage+Reps.h"

@interface DimRepresentationsViewController ()

@property (weak) IBOutlet DimWindowController *windowController;
@property (weak) IBOutlet NSSegmentedControl *segmentedControl;
@property (weak) IBOutlet NSMenu *representationsMenu;
@property (weak) IBOutlet NSTextField *scalePercentageTextField;
@property (weak) IBOutlet DimRepView *repView;
@property (weak) IBOutlet DimRepImageView *imgView;
@property (weak) IBOutlet NSButton *drawBorderCheckbox;

@property (retain) NSArray *supportedRepresentations;

@end

@implementation DimRepresentationsViewController

- (void)viewDidAppear {
    self.supportedRepresentations = @[@16, @32, @128, @256, @512];
    
    // populate View Representations menu
    [self.representationsMenu removeAllItems];
    for (NSNumber *r in self.supportedRepresentations) {
        NSString *title = [NSString stringWithFormat:@"%dx%d", [r intValue], [r intValue]];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title
                                                      action:@selector(viewRepresentation:)
                                               keyEquivalent:@""];
        [item setTarget:self];
        [self.representationsMenu addItem:item];
    }
    
    // make segmented control header fill width of window
    [self.segmentedControl setSegmentCount:[self.supportedRepresentations count]];
    NSWindow *w = [self.segmentedControl window];
    CGFloat segWidth = w.frame.size.width / [self.supportedRepresentations count];
    int it = 0;
    for (NSNumber *n in self.supportedRepresentations) {
        NSString *label = [NSString stringWithFormat:@"%dx%d", [n intValue], [n intValue]];
        [self.segmentedControl setLabel:label
                             forSegment:it];
        [self.segmentedControl setWidth:segWidth
                             forSegment:it];
        it += 1;
    }
    
    // Select
    [self selectRepresentationAtIndex:[DEFAULTS integerForKey:@"SelectedRepresentation"]];
}

- (void)selectRepresentationAtIndex:(NSInteger)index {
    
    NSImage *docImg = self.windowController.docImage;
    NSImage *overlayImg = self.windowController.overlayImage;
    
    // Create rect
    NSString *label = [self.segmentedControl labelForSegment:[self.segmentedControl selectedSegment]];
    int dim = [[label componentsSeparatedByString:@"x"][0] intValue];
    NSRect r = NSMakeRect(0, 0, dim, dim);
    
    self.imgView.size = dim;
    self.imgView.frame = r;
    
    NSLog(@"Size. %d", dim);
    
        NSLog(@"DocImage");
        [docImg printRepresentations];
//
//        NSLog(@"OverlayImage");
//        [overlayImg printRepresentations];
    
    // Doc img reg
    NSBitmapImageRep *rep = (NSBitmapImageRep *)[docImg representationForSize:dim scale:2.0f];
//    NSLog([rep description]);
    
    self.imgView.docImgRep = rep;
    
    // Overlay img rep
    rep = (NSBitmapImageRep *)[overlayImg representationForSize:dim scale:2.0f];
    self.imgView.overlayImgRep = rep;
    
    [self.imgView setHidden:NO];
    [self.imgView setNeedsDisplay:YES];
}

- (IBAction)selectRepresentation:(id)sender {
    NSInteger idx = [sender class] == [NSMenuItem class] ? [self.representationsMenu indexOfItem:sender] : [sender intValue];
    [self selectRepresentationAtIndex:idx];
}

- (IBAction)increaseRepScale:(id)sender {
    self.repView.scale += 0.1;
    [self.scalePercentageTextField setStringValue:[NSString stringWithFormat:@"%d%%", (int)(self.repView.scale * 100.0f)]];
}

- (IBAction)decreaseRepScale:(id)sender {
    self.repView.scale -= 0.1;
    [self.scalePercentageTextField setStringValue:[NSString stringWithFormat:@"%d%%", (int)(self.repView.scale * 100.0f)]];
}

- (IBAction)aspectFit:(id)sender {
    [self.repView aspectFit];
}

- (IBAction)fitToActualSize:(id)sender {
    [self.repView fitToActualSize];
    [self.scalePercentageTextField setStringValue:[NSString stringWithFormat:@"%d%%", (int)(self.repView.scale * 100.0f)]];
}

- (IBAction)nextRepresentation:(id)sender {
    NSInteger sel = [self.segmentedControl selectedSegment];
    sel += 1;
    if (sel > [self.segmentedControl segmentCount]-1) {
        sel = 0;
    }
    [self.segmentedControl setIntegerValue:sel];
    [self selectRepresentation:sender];
}

- (IBAction)previousRepresentation:(id)sender {
    NSInteger sel = [self.segmentedControl selectedSegment];
    sel -= 1;
    if (sel < 0) {
        sel = [self.segmentedControl segmentCount]-1;
    }
    [self.segmentedControl setIntegerValue:sel];
    [self selectRepresentation:sender];
}

- (IBAction)viewRepresentation:(id)sender {
    for (int i = 0; i < [self.segmentedControl segmentCount]; i++) {
        
        if ([[sender title] isEqualToString:[self.segmentedControl labelForSegment:i]]) {
            [self.segmentedControl setIntegerValue:i];
            [self selectRepresentation:sender];
            break;
        }
    }
}

@end
