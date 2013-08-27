//
//  iSXRoundedImageView.m
//  iOScanX
//
//  Created by Alessio Maffeis on 05/08/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXRoundedImageView.h"

@implementation iSXRoundedImageView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self setWantsLayer:YES];
    self.layer.cornerRadius = 13.5;
    self.layer.masksToBounds = YES;
    [super drawRect:dirtyRect];
    
}

@end
