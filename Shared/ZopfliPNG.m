//
//  ZopfliPNG.m
//  DocumentIconMaker
//
//  Created by Sveinbjorn Thordarson on 26/02/16.
//  Copyright © 2016 Sveinbjorn Thordarson. All rights reserved.
//

#import "ZopfliPNG.h"
#import "Common.h"
#import <Cocoa/Cocoa.h>

@implementation ZopfliPNG

+ (BOOL)optimizePNGFileAtPath:(NSString *)path {
    return [ZopfliPNG optimizePNGFileAtPath:path error:nil];
}

+ (BOOL)optimizePNGFileAtPath:(NSString *)path error:(NSError **)error {
    NSString *zopfliPath = [ZopfliPNG findCommandLineProgramNamed:@"zopflipng"];
    if (zopfliPath == nil) {
        NSDictionary *info = @{
            NSLocalizedDescriptionKey: @"Unable to find a zopflipng binary on your system.",
            NSLocalizedRecoverySuggestionErrorKey: @"Have you tried installing zopflipng?"
        };
        *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:info];
        return NO;
    }
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = zopfliPath;
    task.arguments = @[@"-y", path, path];
    task.standardOutput = [NSFileHandle fileHandleWithNullDevice];
    task.standardError = [NSFileHandle fileHandleWithNullDevice];
    [task launch];
    [task waitUntilExit];
    
    return YES;
}

#pragma mark -

+ (BOOL)optimizePNGsInDirectory:(NSString *)directoryPath {
    return [ZopfliPNG optimizePNGsInDirectory:directoryPath error:nil];
}

+ (BOOL)optimizePNGsInDirectory:(NSString *)directoryPath error:(NSError **)error {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Get list of PNG files in directory
    NSArray *dirFiles = [fm contentsOfDirectoryAtPath:directoryPath error:error];
    if (dirFiles == nil) {
        return NO;
    }
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"self ENDSWITH '.png'"];
    NSArray *pngFiles = [dirFiles filteredArrayUsingPredicate:pred];
    
    unsigned long long originalTotalFileSize = 0;
    unsigned long long optimizedTotalFileSize = 0;
    
    // Run zopflipng on each of the png files
    for (NSString *fn in pngFiles) {
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", directoryPath, fn];
        
        unsigned long long size = [[fm attributesOfItemAtPath:fullPath error:nil] fileSize];
        originalTotalFileSize += size;
        
        BOOL success = [ZopfliPNG optimizePNGFileAtPath:fullPath error:error];
        if (!success) {
            return NO;
        }
        
        unsigned long long optSize = [[fm attributesOfItemAtPath:fullPath error:nil] fileSize];
        optimizedTotalFileSize += optSize;
        
        if (size) {
            float perc = 100.f - ((float)optSize / (float)size) * 100;
            NSLog(@"Optimizing %@: %llu --> %llu (-%.1f%%)", fn, size, optSize, perc);
        }
    }
    
    if (originalTotalFileSize) {
        float perc = 100.f - ((float)optimizedTotalFileSize / (float)originalTotalFileSize) * 100;
        NSLog(@"Result for %lu files: %llu --> %llu (-%.1f%%)",
                (unsigned long)[pngFiles count], originalTotalFileSize, optimizedTotalFileSize, perc);
    }

    return YES;
}

#pragma mark -

+ (NSString *)findCommandLineProgramNamed:(NSString *)progName {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Is the binary included in with the currently running app?
    NSString *progPath = [[NSBundle mainBundle] pathForResource:progName ofType:nil];
    if (progPath) {
        return progPath;
    }
    
    // Try to find zopflipng binary in app bundle
    NSString *appPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:PROGRAM_BUNDLE_IDENTIFIER];
    if (appPath) {
        progPath = [[NSBundle bundleWithPath:appPath] pathForResource:progName ofType:nil];
        if (progPath && [fm isExecutableFileAtPath:progPath]) {
            return progPath;
        }
    }
    
    // Check /usr/local/bin
    NSString *testPath1 = [NSString stringWithFormat:@"/usr/local/bin/%@", progName];
    NSString *testPath2 = [[NSString stringWithFormat:@"~/bin/%@", progName] stringByExpandingTildeInPath];
    for (NSString *path in @[testPath1, testPath2]) {
        if ([fm isExecutableFileAtPath:path]) {
            return path;
        }
    }
    
    // Launch tasks in order to try to locate a zopflipng binary
    for (NSString *task in @[@"/usr/bin/which", @"/usr/bin/locate"]) {
        NSTask *findTask = [[NSTask alloc] init];
        [findTask setLaunchPath:task];
        [findTask setArguments:@[progName]];
        
        NSPipe *outputPipe = [NSPipe pipe];
        [findTask setStandardOutput:outputPipe];
        NSFileHandle *readHandle = [outputPipe fileHandleForReading];
        
        [findTask launch];
        [findTask waitUntilExit];
        
        NSData *outputData = [readHandle readDataToEndOfFile];
        NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        
        NSArray *results = [outputString componentsSeparatedByString:@"\n"];
        NSString *filterStr = [NSString stringWithFormat:@"self ENDSWITH '%@'", progName];
        results = [results filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:filterStr]];
        
        for (NSString *r in results) {
            if ([[NSFileManager defaultManager] isExecutableFileAtPath:r]) {
                return r;
            }
        }
    }
    return nil;
}

@end
