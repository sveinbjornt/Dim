
#import "NonInterpolatedImageView.h"

@implementation NonInterpolatedImageView

- (void)drawRect:(NSRect)rect
{
	[NSGraphicsContext saveGraphicsState];
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
	[super drawRect:rect];
	[NSGraphicsContext restoreGraphicsState];
}

@end
