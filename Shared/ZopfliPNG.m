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
    NSString *zopfliPath = [ZopfliPNG findCommandLineProgramNamed:@"zopflipng"];
    if (zopfliPath == nil) {
        NSLog(@"No zopflipng program found");
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

+ (NSString *)findCommandLineProgramNamed:(NSString *)progName {
    // Is the binary included in with the running app?
    NSString *progPath = [[NSBundle mainBundle] pathForResource:progName ofType:nil];
    if (progPath) {
        return progPath;
    }
    
    // Try to find Dim app
    NSString *appPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:PROGRAM_BUNDLE_IDENTIFIER];
    if (appPath) {
        progPath = [[NSBundle bundleWithPath:appPath] pathForResource:progName ofType:nil];
        if (progPath) {
            return progPath;
        }
    }
    
    // Check /usr/local/bin
    progPath = [NSString stringWithFormat:@"/usr/local/bin/%@", progName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:progPath]) {
        return progPath;
    }
    
    // Launch 'find' task in order to try to locate a zopflipng binary
    NSTask *findTask = [[NSTask alloc] init];
    [findTask setLaunchPath:@"/usr/bin/locate"];
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
    NSPredicate *pred = [NSPredicate predicateWithFormat:filterStr];
    results = [results filteredArrayUsingPredicate:pred];

    for (NSString *r in results) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:r]) {
            return r;
        }
    }
    
    return nil;
}

+ (BOOL)optimizePNGsInDirectory:(NSString *)directoryPath {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if (![fm fileExistsAtPath:directoryPath isDirectory:&isDir] || !isDir) {
        return NO;
    }
    
    NSArray *dirFiles = [fm contentsOfDirectoryAtPath:directoryPath error:nil];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"self ENDSWITH '.png'"];
    NSArray *pngFiles = [dirFiles filteredArrayUsingPredicate:pred];
    
    unsigned long long originalTotalFileSize = 0;
    unsigned long long optimizedTotalFileSize = 0;
    
    for (NSString *fn in pngFiles) {
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", directoryPath, fn];
        
        unsigned long long size = [[fm attributesOfItemAtPath:fullPath error:nil] fileSize];
        originalTotalFileSize += size;
        
        [ZopfliPNG optimizePNGFileAtPath:fullPath];
        
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


@end
