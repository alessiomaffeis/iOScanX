//
//  iSXAppsViewController.m
//  iOScanX
//
//  Created by Alessio Maffeis on 28/05/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXAppsViewController.h"

@interface iSXAppsViewController ()

@end

@implementation iSXAppsViewController {
    
    IBOutlet NSArrayController *_appsArrayController;

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _apps = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addApp:(iSXApp *)app {
    
    [_appsArrayController addObject:app];
}

- (NSArray*)selectedApps {
    
    return nil;
}

- (void)dealloc {
    
    [_apps release];
    [super dealloc];
}

@end
