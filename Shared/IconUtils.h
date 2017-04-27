//
//  IconUtils.h
//  Dim
//
//  Created by Sveinbjorn Thordarson on 27/04/2017.
//  Copyright © 2017 Sveinbjorn Thordarson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IconUtils : NSObject

+ (BOOL)convertIconSet:(NSString *)iconsetPath toIcns:(NSString *)outputIcnsPath;

@end
