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
+ (BOOL)optimizePNGFileAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)optimizePNGsInDirectory:(NSString *)directoryPath;
+ (BOOL)optimizePNGsInDirectory:(NSString *)directoryPath error:(NSError **)error;



@end
