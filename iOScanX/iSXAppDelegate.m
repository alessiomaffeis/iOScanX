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
#import "iSXResultsTransformer.h"


@implementation iSXAppDelegate {
    
    NSMutableArray *_openedModules;
    BOOL _didFinishLaunching;
}

+ (void)initialize {
    
    iSXMetricsTransformer *metricsTransformer = [[[iSXMetricsTransformer alloc] init] autorelease];
    iSXResultsTransformer *resultsTransformer = [[[iSXResultsTransformer alloc] init] autorelease];

    [NSValueTransformer setValueTransformer:metricsTransformer
                                    forName:@"MetricsTransformer"];
    [NSValueTransformer setValueTransformer:resultsTransformer
                                    forName:@"ResultsTransformer"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [(iSXAppController*)_window.delegate initialize];
    _didFinishLaunching = YES;
    if(_openedModules != nil && _openedModules.count>0)
    {
        [(iSXAppController*)_window.delegate addModules:_openedModules];
        [_openedModules removeAllObjects];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
    
    if(_openedModules == nil)
    {
        _openedModules = [[NSMutableArray alloc] init];
        [_openedModules addObject:[NSURL fileURLWithPath:filename]];
    }
    else
    {
        [_openedModules addObject:[NSURL fileURLWithPath:filename]];
        if ([(iSXAppController*)_window.delegate addModules:_openedModules])
            [_openedModules removeAllObjects];
    }
    
    if(_didFinishLaunching)
    {
        [(iSXAppController*)_window.delegate addModules:_openedModules];
        [_openedModules removeAllObjects];
    }
    
    return YES;
}

- (void)application:(NSApplication *)theApplication openFiles:(NSArray *)filenames {
    
    if(_openedModules == nil)
    {
        _openedModules = [[NSMutableArray alloc] init];
        for (NSString *filename in filenames) {
            [_openedModules addObject:[NSURL fileURLWithPath:filename]];
        }
    }
    else
    {
        for (NSString *filename in filenames) {
            [_openedModules addObject:[NSURL fileURLWithPath:filename]];
        }
        if ([(iSXAppController*)_window.delegate addModules:_openedModules])
            [_openedModules removeAllObjects];
    }
    
    if(_didFinishLaunching)
    {
        [(iSXAppController*)_window.delegate addModules:_openedModules];
        [_openedModules removeAllObjects];
    }
}


- (void)dealloc
{
    [super dealloc];
}

@end
