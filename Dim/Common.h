//
//  Common.h
//  DocumentIconMaker
//
//  Created by Sveinbjorn Thordarson on 07/02/16.
//  Copyright © 2016 Sveinbjorn Thordarson. All rights reserved.
//

#define PROGRAM_NAME						@"Dim"
#define PROGRAM_VERSION						@"1.0"
#define	PROGRAM_WEBSITE						@"http://sveinbjorn.org/dim"
#define	PROGRAM_GITHUB_WEBSITE              @"http://github.com/sveinbjornt/Dim"
#define PROGRAM_DONATIONS					@"http://sveinbjorn.org/donations"
#define PROGRAM_LICENSE_URL					@"http://sveinbjorn.org/bsd_license"
#define PROGRAM_BUNDLE_IDENTIFIER           @"org.sveinbjorn.Dim"

#define FILEMGR                             [NSFileManager defaultManager]
#define DEFAULTS                            [NSUserDefaults standardUserDefaults]
#define WORKSPACE                           [NSWorkspace sharedWorkspace]

#define DEFAULT_LABEL_FONT                  @"Helvetica"
#define DEFAULT_LABEL_COLOR                 [NSColor grayColor]

#define DEFAULT_OVERLAY_SIZE                0.5
#define DEFAULT_OVERLAY_XOFFSET             0.f
#define DEFAULT_OVERLAY_YOFFSET             0.f
#define DEFAULT_OVERLAY_OPACITY             1.0f

#define DEFAULT_XOFFSET_WIIHOUT_LABEL       10.0f
#define DEFAULT_YOFFSET_WIIHOUT_LABEL       10.0f

#define DEFAULT_DOCUMENT_ICON_PATH  \
@"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericDocumentIcon.icns"

#define DEFAULT_OVERLAY_ICON_PATH   \
[[NSBundle mainBundle] pathForResource:@"AppIcon" ofType:@"icns"]
