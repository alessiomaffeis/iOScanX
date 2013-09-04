//
//  iSXAppView.m
//  iOScanX
//
//  Created by Alessio Maffeis on 03/09/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXAppView.h"

@implementation iSXAppView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
    if (_selected) {
        [[NSColor colorWithCalibratedHue:.21 saturation:.04 brightness:.94 alpha:1] set];
        NSRectFill([self bounds]);
    }
}

@end
