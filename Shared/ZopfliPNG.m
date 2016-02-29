//
//  ZopfliPNG.m
//  DocumentIconMaker
//
//  Created by Sveinbjorn Thordarson on 26/02/16.
//  Copyright © 2016 Sveinbjorn Thordarson. All rights reserved.
//

#import "ZopfliPNG.h"

@implementation ZopfliPNG

- (BOOL)optimizePNGFileAtPath:(NSString *)path {
    NSString *zopfliPath = [[NSBundle mainBundle] pathForResource:@"zopflipng" ofType:nil];
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = zopfliPath;
    task.arguments = @[path, path];
    [task launch];
    [task waitUntilExit];
    
    return YES;
}

@end
