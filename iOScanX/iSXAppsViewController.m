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

-(void)awakeFromNib {
    
    [_appsArrayController setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease]]];
}

- (BOOL)appExistsWithID:(NSString*)appID {
    
    for (iSXApp *app in _appsArrayController.arrangedObjects) {
        if ([app.ID isEqualToString:appID]) {
            return YES;
        }
    }
    return NO;
}

- (void)addApp:(iSXApp *)app {
    
    [_appsArrayController addObject:app];
}

- (NSArray*)selectedApps {
    
    NSMutableArray *sel = [NSMutableArray array];
    for (iSXApp *app in _appsArrayController.arrangedObjects) {
        if (app.analyze) {
            [sel addObject:app];
        }
    }
    return [NSArray arrayWithArray:sel];
}

- (void)dealloc {
    
    [_apps release];
    [super dealloc];
}

@end
