//
//  ZopfliPNG.h
//  DocumentIconMaker
//
//  Created by Sveinbjorn Thordarson on 26/02/16.
//  Copyright © 2016 Sveinbjorn Thordarson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZopfliPNG : NSObject

+ (BOOL)optimizePNGFileAtPath:(NSString *)path;
+ (BOOL)optimizePNGsInDirectory:(NSString *)directoryPath;

@end
