//
//  iSXAppDelegate.m
//  iOScanX
//
//  Created by Alessio Maffeis on 06/03/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXAppDelegate.h"

@implementation iSXAppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [_window.delegate initialize];
}

@end
