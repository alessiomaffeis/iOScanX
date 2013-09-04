//
//  iSXTextFieldCell.m
//  iOScanX
//
//  Created by Alessio Maffeis on 04/09/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXTextFieldCell.h"

@implementation iSXTextFieldCell {
    
    BOOL _isSelecting;
}


- (NSRect)drawingRectForBounds:(NSRect)rect {

	NSRect newRect = [super drawingRectForBounds:rect];
	if (_isSelecting == NO)
	{
		NSSize textSize = [self cellSizeForBounds:rect];
        
		float delta = newRect.size.height - textSize.height;
		if (delta > 0)
		{
			newRect.size.height -= delta;
			newRect.origin.y += (delta / 2) - 2;
		}
	}
	
	return newRect;
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
    
	aRect = [self drawingRectForBounds:aRect];
	_isSelecting = YES;
	[super selectWithFrame:aRect inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
	_isSelecting = NO;
}

@end
