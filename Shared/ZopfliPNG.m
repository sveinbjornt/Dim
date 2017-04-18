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

@end
