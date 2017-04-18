//
//  ZopfliPNG.m
//  DocumentIconMaker
//
//  Created by Sveinbjorn Thordarson on 26/02/16.
//  Copyright © 2016 Sveinbjorn Thordarson. All rights reserved.
//

#import "ZopfliPNG.h"

@implementation ZopfliPNG

+ (BOOL)optimizePNGFileAtPath:(NSString *)path {
    NSString *zopfliPath = [ZopfliPNG findCommandLineProgramNamed:@"zopflipng"];
    if (!zopfliPath) {
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
    NSString *zopfliPath = [[NSBundle mainBundle] pathForResource:@"zopflipng" ofType:nil];
    if (zopfliPath) {
        return zopfliPath;
    }
    
    return @"/usr/local/bin/zopflipng";
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
