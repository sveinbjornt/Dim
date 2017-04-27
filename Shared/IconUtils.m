//
//  IconUtils.m
//  Dim
//
//  Created by Sveinbjorn Thordarson on 27/04/2017.
//  Copyright © 2017 Sveinbjorn Thordarson. All rights reserved.
//

#import "IconUtils.h"

#define ICONUTIL_PATH   @"/usr/bin/iconutil"

@implementation IconUtils

+ (BOOL)convertIconSet:(NSString *)iconsetPath toIcns:(NSString *)outputIcnsPath {
    NSString *iconutilPath = ICONUTIL_PATH;
    if (![[NSFileManager defaultManager] fileExistsAtPath:iconutilPath]) {
        NSLog(@"%@ not installed on this system", iconutilPath);
        return NO;
    }
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = iconutilPath;
    task.arguments = @[@"--convert", @"icns", @"--output", outputIcnsPath, iconsetPath];
    task.standardOutput = [NSFileHandle fileHandleWithNullDevice];
    task.standardError = [NSFileHandle fileHandleWithNullDevice];
    [task launch];
    [task waitUntilExit];
    
    return YES;
}

@end
