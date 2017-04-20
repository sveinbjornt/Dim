//
//  main.m
//  dim
//
//  Created by Sveinbjorn Thordarson on 18/04/2017.
//  Copyright © 2017 Sveinbjorn Thordarson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <getopt.h>

#import "Common.h"
#import "DimComposition.h"
#import "IconFamily.h"
#import "ZopfliPNG.h"
#import "NSColor+HexTools.h"

static void PrintVersion(void);
static void PrintHelp(void);
static void NSPrintErr(NSString *format, ...);
static void NSPrint(NSString *format, ...);

static const char optstring[] = "b:l:S:C:F:z:x:y:p:niofvh";

static struct option long_options[] =
{
    {"baseicon",                required_argument,      0,  'b'},
    
    {"labels",                  required_argument,      0,  'l'},
    {"label-size",              required_argument,      0,  'S'},
    {"label-color",             required_argument,      0,  'C'},
    {"label-font",              required_argument,      0,  'F'},
    
    {"overlay-size",            required_argument,      0,  'z'},
    {"overlay-xoffset",         required_argument,      0,  'x'},
    {"overlay-yoffset",         required_argument,      0,  'y'},
    {"overlay-opacity",         required_argument,      0,  'p'},
    {"overlay-sharpen",         required_argument,      0,  's'},
    
    {"representations",         required_argument,      0,  'r'},
    {"no-high-res",             no_argument,            0,  'g'},
    
    {"iconset-only",            no_argument,            0,  'n'},
    {"icns-only",               no_argument,            0,  'i'},
    
    {"optimize-images",         no_argument,            0,  'o'},
    
    {"force",                   no_argument,            0,  'f'},
    
    {"version",                 no_argument,            0,  'v'},
    {"help",                    no_argument,            0,  'h'},
    {0,                         0,                      0,    0}
};

int main(int argc, const char * argv[]) { @autoreleasepool {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *destination;
    
    NSString *baseIconPath = DEFAULT_DOCUMENT_ICON_PATH;
    
    NSMutableArray *labels = [NSMutableArray array];
    float labelFontSize = 1.0;
    NSColor *labelColor = [NSColor grayColor];
    NSFont *labelFont = [NSFont fontWithName:@"Helvetica" size:10];
    
    BOOL iconsetOnly = NO; // default output is both iconset and icns
    BOOL icnsOnly = NO;    // default output is both iconset and icns
    BOOL optimizeImages = NO; // crush pngs with zopfli
    BOOL overwrite = NO;
    
    float overlaySize = DEFAULT_OVERLAY_SIZE;
    float xoffset = 0;
    float yoffset = 0;
    float opacity = 1.0f;
    float overlaySharpenSize = 2048;
    
    NSMutableSet *representations = [NSMutableSet set];
    BOOL excludeHighResReps = NO;
    
    // -------------------------------------
    
    int optch;
    int long_index = 0;
    while ((optch = getopt_long(argc, (char *const *)argv, optstring, long_options, &long_index)) != -1) {
    
        switch (optch) {
                
            // labels
            case 'l':
            {
                NSString *argStr = @(optarg);
                [labels addObjectsFromArray:[argStr componentsSeparatedByString:@","]];
            }
                break;
            
            case 'S':
                // label size
                labelFontSize = [@(optarg) floatValue];
                break;
                
            case 'C':
            {
                // label color
                NSString *arg = @(optarg);
                NSColor *c = [NSColor colorFromHexString:arg];
                if (c) {
                    labelColor = c;
                } else {
                    NSPrintErr(@"Unable to create color from '%@'. Using default color.", arg);
                }
            }
                break;
                
            case 'F':
            {
                NSString *arg = @(optarg);
                NSFont *f = [NSFont fontWithName:arg size:10];
                if (f) {
                    labelFont = f;
                } else {
                    NSPrintErr(@"Unable to instantiate font '%@'. Using default font.", arg);
                }
            }
                break;
                
            case 'b':
                baseIconPath = @(optarg);
                break;
            
            case 'f':
                overwrite = YES;
                break;
                
            case 'n':
                iconsetOnly = YES;
                break;
                
            case 'i':
                icnsOnly = YES;
                break;
                
            case 'o':
                optimizeImages = YES;
                break;
            
            case 'z':
                overlaySize = [@(optarg) floatValue];
                break;
            
            case 'x':
                xoffset = [@(optarg) floatValue];
                break;
                
            case 'y':
                yoffset = [@(optarg) floatValue];
                break;
                
            case 'p':
                opacity = [@(optarg) floatValue];
                break;
                
            case 's':
                overlaySharpenSize = [@(optarg) floatValue];
                break;
                
            case 'r':
            {
                NSString *arg = @(optarg);
                NSArray *items = [arg componentsSeparatedByString:@","];
                [representations addObjectsFromArray:items];
            }
                break;
                
            case 'g':
                excludeHighResReps = YES;
                break;
                
            // print version
            case 'v':
            {
                PrintVersion();
                exit(0);
            }
                break;
                
            // print help with list of options
            case 'h':
            default:
            {
                PrintHelp();
                exit(0);
            }
                break;
        }
    }
    
    // read remaining args
    NSMutableArray *remainingArgs = [NSMutableArray array];
    while (optind < argc) {
        NSString *argStr = @(argv[optind]);
        [remainingArgs addObject:argStr];
        optind += 1;
    }
    
    // we always need one more argument, either script file path or app name
    if ([remainingArgs count] == 0) {
        NSPrintErr(@"Error: Missing argument");
        PrintHelp();
        exit(1);
    }
    
    NSString *overlayIconPath = remainingArgs[0];
    
    if ([remainingArgs count] >= 2) {
        destination = remainingArgs[1]; // we're receiving destination path
    } else {
        destination = [overlayIconPath stringByDeletingLastPathComponent];
    }
    
    // Read icons
    IconFamily *baseIconFam = [IconFamily iconFamilyWithContentsOfFile:baseIconPath];
    IconFamily *overlayIconFam = [IconFamily iconFamilyWithContentsOfFile:overlayIconPath];
    
    NSImage *baseImage = [baseIconFam imageWithAllReps];
    NSImage *overlayImage = [overlayIconFam imageWithAllReps];
  
    // Create composition
    DimComposition *composition = [[DimComposition alloc] initWithBaseImage:baseImage
                                                               overlayImage:overlayImage];
    if (!composition) {
        NSPrintErr(@"Failed to creation composition from paths:\n\t%@\n\t%@", baseIconPath, overlayIconPath);
        exit(1);
    }
    
    // configure composition based on parameters
    composition.overlaySize = overlaySize;
    composition.overlayXOffset = xoffset;
    composition.overlayYOffset = yoffset;
    composition.overlayOpacity = opacity;
    composition.labelFontSize = labelFontSize;
    composition.labelFont = labelFont;
    composition.labelColor = labelColor;
    
    // Create output path
    NSString *name = [[overlayIconPath lastPathComponent] stringByDeletingPathExtension];
    NSString *iconsetFileName = [NSString stringWithFormat:@"%@-Document.%@", name, @"iconset"];
    NSString *icnsFileName = [NSString stringWithFormat:@"%@-Document.%@", name, @"icns"];
    
    // If it's a folder which isn't an iconset, it's a destination folder
    // so we append the newe filename generated from the overlay icon filename
    BOOL isFolder = NO;
    BOOL exists = [fm fileExistsAtPath:destination isDirectory:&isFolder];
    if (exists && isFolder && ![destination hasSuffix:@"iconset"]) {
        destination = [NSString stringWithFormat:@"%@/%@", destination, iconsetFileName];
    }
    
    // Only overwrite if -f flag
    if ([fm fileExistsAtPath:destination]) {
        if (!overwrite) {
            NSPrintErr(@"File already exists at path. Use -f to overwrite.");
            exit(1);
        }
    }
    
    // Generate output files
    // first, create an iconset
    BOOL success = [composition createIconSetAtPath:destination];
    if (!success) {
        NSPrintErr(@"Error creating icon set %@", destination);
        exit(1);
    }
    
    // Optimization
    if (optimizeImages) {
        NSPrint(@"Optimizing images in directory %@", destination);
        NSError *err;
        BOOL success = [ZopfliPNG optimizePNGsInDirectory:destination error:&err];
        if (!success) {
            NSPrintErr(@"Error optimizing images: %@", [err localizedDescription]);
        }
    }
    
    // create icns file from iconset
    if (iconsetOnly == NO) {
        NSString *icnsPath = [NSString stringWithFormat:@"%@/%@",
                              [destination stringByDeletingLastPathComponent], icnsFileName];

        [DimComposition convertIconSet:destination toIcns:icnsPath];
    }

    // Get rid of iconset if user wants icns only
    if (icnsOnly) {
        [fm removeItemAtPath:destination error:nil];
    }

} return 0; }

static void PrintVersion(void) {
    NSPrint(@"dim version %@", PROGRAM_VERSION);
}

static void PrintHelp(void) {
    NSPrint(@"\
usage: dim overlayIcon [destination] [--labels one,two,three] \
[--baseicon iconPath] [--force]\n\
");
}

#pragma mark -

// print to stdout
static void NSPrint(NSString *format, ...) {
    va_list args;
    
    va_start(args, format);
    NSString *string  = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    fprintf(stdout, "%s\n", [string UTF8String]);
}

// print to stderr
static void NSPrintErr(NSString *format, ...) {
    va_list args;
    
    va_start(args, format);
    NSString *string  = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    fprintf(stderr, "%s\n", [string UTF8String]);
}
