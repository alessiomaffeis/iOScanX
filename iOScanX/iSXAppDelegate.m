//
//  iSXAppDelegate.m
//  iOScanX
//
//  Created by Alessio Maffeis on 06/03/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXAppDelegate.h"
#import "iSXAppController.h"
#import "iSXMetricsTransformer.h"


@implementation iSXAppDelegate

+ (void)initialize {
    
    iSXMetricsTransformer *metricsTransformer = [[[iSXMetricsTransformer alloc] init] autorelease];
    [NSValueTransformer setValueTransformer:metricsTransformer
                                    forName:@"MetricsTransformer"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [(iSXAppController*)_window.delegate initialize];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
    return [(iSXAppController*)_window.delegate addModule:filename];
}

- (void)dealloc
{
    [super dealloc];
}

@end
