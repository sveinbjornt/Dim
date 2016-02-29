//
//  DIMWindowController.m
//  DocumentIconMaker
//
//  Created by Sveinbjorn Thordarson on 06/02/16.
//  Copyright © 2016 Sveinbjorn Thordarson. All rights reserved.
//

#import "DimWindowController.h"
#import "IconFamily.h"
#import "Common.h"
#import "DimRepresentationsViewController.h"
#import "DimRepImageView.h"
#import "NSImage+Reps.h"

@interface DimWindowController ()
{
    NSMutableArray *labels;
}

@property (retain) NSArray *docRepresentations;

@property (weak) IBOutlet NSButton *documentImageCheckbox;
@property (weak) IBOutlet NSButton *overlayImageCheckbox;
@property (weak) IBOutlet NSButton *labelsCheckbox;

@property (weak) IBOutlet NSImageView *docImageView;
@property (weak) IBOutlet NSImageView *overlayImageView;

@property (weak) IBOutlet DimRepImageView *resultImageView;

@property (weak) IBOutlet NSTableView *labelsTableView;

@property (weak) IBOutlet NSSlider *overlaySizeSlider;
@property (weak) IBOutlet NSSlider *overlayXSlider;
@property (weak) IBOutlet NSSlider *overlayYSlider;

@property (weak) IBOutlet NSTextField *labelFontNameTextField;
@property (weak) IBOutlet NSSlider *labelFontSizeSlider;
@property (weak) IBOutlet NSSlider *labelFontXSlider;
@property (weak) IBOutlet NSSlider *labelFontYSlider;

@property (weak) IBOutlet NSTextField *toggleRepresentationsTextField;

@property (weak) IBOutlet DimRepresentationsViewController *repController;




@end

@implementation DimWindowController

+ (void)initialize {
    NSString *defaultsPath = [[NSBundle mainBundle] pathForResource:@"RegistrationDefaults" ofType:@"plist"];
    NSDictionary *registrationDefaults = [NSDictionary dictionaryWithContentsOfFile:defaultsPath];
    [DEFAULTS registerDefaults:registrationDefaults];
}

- (void)awakeFromNib {
    
    // put application icon in window title bar
    [self.window setRepresentedURL:[NSURL URLWithString:@""]];
    NSButton *button = [self.window standardWindowButton:NSWindowDocumentIconButton];
    [button setImage:[NSApp applicationIconImage]];

    
    // Observe defaults
    for (NSString *key in @[@"DocumentIconPath", @"OverlayIconPath"]) {
        NSString *keyPath = [NSString stringWithFormat:@"values.%@", key];
        [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                                  forKeyPath:keyPath
                                                                     options:NSKeyValueObservingOptionNew
                                                                     context:NULL];
    }
    
    // Load labels
    labels = [@[@"LABEL"] mutableCopy];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    [self.labelsTableView selectRowIndexes:indexSet byExtendingSelection:NO];

    // Load icons
    if ([self loadDocumentIcon:[DEFAULTS objectForKey:@"DocumentIconPath"]] == NO) {
        [self loadDocumentIcon:DEFAULT_DOCUMENT_ICON_PATH];
    }
    
    if ([self loadOverlayIcon:[DEFAULTS objectForKey:@"OverlayIconPath"]] == NO) {
        [self loadOverlayIcon:DEFAULT_OVERLAY_ICON_PATH];
    }
    
//    for (NSImageRep *imgRep in self.representations) {
//        NSLog(@"%d x %d", [imgRep pixelsWide], [imgRep pixelsHigh]);
////        [imgRep size];
//        //    NSSize pixelSize = NSMakeSize();
//    }
    
    [self toggleRepresentations:self];
    
    [self.window center];
    [self.window makeKeyAndOrderFront:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.resultImageView.docImgRep = [[self docImage] representationForSize:128 scale:2.0f];
    self.resultImageView.overlayImgRep = [[self overlayImage] representationForSize:128 scale:2.0f];
}

- (NSImage *)docImage {
    return [self.docImageView image];
}

- (NSImage *)overlayImage {
    return [self.overlayImageView image];
}

#pragma mark - Load icons

- (IBAction)selectDocumentIcon:(id)sender {
    [self.window setTitle:[NSString stringWithFormat:@"%@ - Select Document Icon", PROGRAM_NAME]];
    
    // create open panel
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setPrompt:@"Select"];
    [oPanel setAllowsMultipleSelection:NO];
    [oPanel setCanChooseDirectories:NO];
    [oPanel setAllowedFileTypes:@[(NSString *)kUTTypeAppleICNS]];
    
    //run open panel
    [oPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        [self.window setTitle:PROGRAM_NAME];
        if (result == NSOKButton) {
            NSString *filePath = [[oPanel URLs][0] path];
            [self loadDocumentIcon:filePath];
        }
    }];
}

- (IBAction)selectOverlayIcon:(id)sender {
    [self.window setTitle:[NSString stringWithFormat:@"%@ - Select Overlay Icon", PROGRAM_NAME]];
    
    // create open panel
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setPrompt:@"Select"];
    [oPanel setAllowsMultipleSelection:NO];
    [oPanel setCanChooseDirectories:NO];
    [oPanel setAllowedFileTypes:@[(NSString *)kUTTypeAppleICNS]];
    
    //run open panel
    [oPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        [self.window setTitle:PROGRAM_NAME];
        if (result == NSOKButton) {
            NSString *filePath = [[oPanel URLs][0] path];
            [self loadOverlayIcon:filePath];
            [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:filePath]];
        }
    }];
}

- (BOOL)loadDocumentIcon:(NSString *)docIconPath {
    IconFamily *iconFamily = [IconFamily iconFamilyWithContentsOfFile:docIconPath];
    NSImage *docImage = [iconFamily imageWithAllReps];
    if (iconFamily == nil || docImage == nil) {
        NSLog(@"Unable to load document icon");
        return NO;
    }
    
    [[self docImageView] setImage:docImage];

    [DEFAULTS setObject:docIconPath forKey:@"DocumentIconPath"];
    
    return YES;
}

- (BOOL)loadOverlayIcon:(NSString *)overlayIconPath {
    IconFamily *iconFamily = [IconFamily iconFamilyWithContentsOfFile:overlayIconPath];
    NSImage *overlayImage = [iconFamily imageWithAllReps];
    if (iconFamily == nil || overlayImage == nil) {
        NSLog(@"Unable to load overlay icon");
        return NO;
    }
    
    [[self overlayImageView] setImage:overlayImage];
    
    [DEFAULTS setObject:overlayIconPath forKey:@"OverlayIconPath"];
    
    return YES;
}

#pragma mark -

- (IBAction)restoreDefaultIcon:(id)sender {
    [self loadDocumentIcon:DEFAULT_DOCUMENT_ICON_PATH];
}

- (IBAction)copyIcon:(id)sender {
    
}

- (IBAction)selectIcon:(id)sender {
    [self selectOverlayIcon:sender];
}

- (IBAction)restoreDefaults:(id)sender {
    [DEFAULTS setInteger:50 forKey:@"OverlaySize"];
    [DEFAULTS setInteger:50 forKey:@"OverlayXOffset"];
    [DEFAULTS setInteger:50 forKey:@"OverlayYOffset"];
    [DEFAULTS setInteger:100 forKey:@"LabelFontSizePercentage"];
    [DEFAULTS setInteger:50 forKey:@"LabelXOffset"];
    [DEFAULTS setInteger:50 forKey:@"LabelYOffset"];

    [DEFAULTS setObject:[NSArchiver archivedDataWithRootObject:[NSColor colorWithDeviceWhite:0.34f alpha:1.0f]] forKey:@"LabelColor"];
}

- (IBAction)toggleRepresentations:(id)sender {
    
    BOOL on = [DEFAULTS boolForKey:@"ShowRepresentations"];
    NSInteger repViewHeight = [DEFAULTS integerForKey:@"RepresentationsViewHeight"];
    
    NSSize normalSize = NSMakeSize(684, 300);
    
    NSRect f = self.window.frame;
    
    if (on) {
        f.origin.y -= repViewHeight;
        f.size.height += repViewHeight;
        [self.window setFrame:f display:YES];
        
        [self.window.contentView addSubview:self.repController.view];
        [self.repController.view setFrame:NSMakeRect(0, 0, f.size.width, repViewHeight)];
        
        [self.window setMinSize:NSMakeSize(684, 420)];
        [self.window setMaxSize:NSMakeSize(684, 65535)];
        
    } else {
        f.origin.y += self.repController.view.frame.size.height;
        f.size.height = normalSize.height;
        
        [self.repController.view setFrame:NSMakeRect(0, 0, f.size.width, repViewHeight)];
        [self.repController.view removeFromSuperview];
        
        [self.window setMinSize:normalSize];
        [self.window setMaxSize:normalSize];
        
        [self.window setFrame:f display:YES];
    }
    
    [DEFAULTS setInteger:self.repController.view.frame.size.height
                  forKey:@"RepresentationsViewHeight"];
}

#pragma mark - Create

- (IBAction)create:(id)sender {
    
}

#pragma mark - Font Manager

- (IBAction)chooseFont:(id)sender {
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *currentFont = [NSFont fontWithName:[DEFAULTS objectForKey:@"LabelFont"] size:12];
    [fontManager setSelectedFont:currentFont isMultiple:NO];
    [fontManager orderFrontFontPanel:nil];
}

// called by the shared NSFontManager when user chooses a new font or size in the Font Panel
- (void)changeFont:(id)sender {
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *font = [fontManager convertFont:[fontManager selectedFont]];
    [DEFAULTS setObject:[font fontName] forKey:@"LabelFont"];
}

#pragma mark - Labels

- (IBAction)addNewLabel:(id)sender {
    [labels addObject:@"LABEL"];
    [self.labelsTableView reloadData];
}

- (IBAction)removeSelectedLabel:(id)sender {
    [labels removeObjectAtIndex:[self.labelsTableView selectedRow]];
    [self.labelsTableView reloadData];
    [self tableViewSelectionDidChange:sender];
}

#pragma mark - NSTableViewDelegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [labels count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return [labels objectAtIndex:rowIndex];
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    labels[rowIndex] = anObject;
    
    NSInteger selectedLabelIndex = [self.labelsTableView selectedRow];
    [DEFAULTS setObject:labels[selectedLabelIndex] forKey:@"CurrentLabel"];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSInteger selectedLabelIndex = [self.labelsTableView selectedRow];
    if (selectedLabelIndex != -1) {
        [DEFAULTS setObject:labels[selectedLabelIndex] forKey:@"CurrentLabel"];
    }
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 20;
}

#pragma mark - Menus

- (IBAction)showLicense:(id)sender {
    [WORKSPACE openURL:[NSURL URLWithString:PROGRAM_LICENSE_URL]];
}

- (IBAction)supportDIMDevelopment:(id)sender {
    [WORKSPACE openURL:[NSURL URLWithString:PROGRAM_DONATIONS]];
}

- (IBAction)visitDIMWebsite:(id)sender {
    [WORKSPACE openURL:[NSURL URLWithString:PROGRAM_WEBSITE]];
}

- (IBAction)visitDIMOnGitHubWebsite:(id)sender {
    [WORKSPACE openURL:[NSURL URLWithString:PROGRAM_GITHUB_WEBSITE]];
}

@end
