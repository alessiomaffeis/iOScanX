//
//  iSXAppController.m
//  iOScanX
//
//  Created by Alessio Maffeis on 28/05/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXAppController.h"
#import "NSFileManager+DirectoryLocations.h"

@implementation iSXAppController {
    
    NSViewController *_appsViewController;
    NSViewController *_modulesViewController;
    NSViewController *_evaluationsViewController;
    NSViewController *_resultsViewController;
    IBOutlet NSArrayController *_appsArrayController;
}

- (id) init {
    [super init];
    if (self) {
        _scanner = [[SXScanner alloc] init];
        _apps = [[NSMutableArray alloc] init];
        _appsViewController = [[iSXAppsViewController alloc] initWithNibName:@"iSXAppsViewController" bundle:nil];
        _modulesViewController = [[iSXModulesViewController alloc] initWithNibName:@"iSXModulesViewController" bundle:nil];
        _evaluationsViewController = [[iSXEvaluationsViewController alloc] initWithNibName:@"iSXEvaluationsViewController" bundle:nil];
        _resultsViewController = [[iSXResultsViewController alloc] initWithNibName:@"iSXResultsViewController" bundle:nil];
    }
    return self;
}

- (void)initialize {
    
   [self.mainView addSubview:[_appsViewController view]];
   [[_appsViewController view] setFrame:[self.mainView bounds]];
}

- (void)loadApps {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *srcPath = [fm iTunesMobileAppsDirectory];    
    NSString *dstPath = [fm applicationSupportSubDirectory:@"Apps"];
    NSDirectoryEnumerator *de = [fm enumeratorAtPath:srcPath];
    
    
    iSXApp *test = [[iSXApp alloc] init];
    [_appsArrayController addObject:test];
    test = [[iSXApp alloc] init];
    [_appsArrayController addObject:test];
    test = [[iSXApp alloc] init];
    [_appsArrayController addObject:test];
    test = [[iSXApp alloc] init];
    [_appsArrayController addObject:test];
    
    
}

// UI related methods:

- (void)awakeFromNib {
    
    [self loadApps];
}

- (IBAction)showApps:(id)sender {
    
    [self.mainView addSubview:[_appsViewController view]];
    [[_appsViewController view] setFrame:[self.mainView bounds]];
}

- (IBAction)showModules:(id)sender {
    
    [self.mainView addSubview:[_modulesViewController view]];
    [[_modulesViewController view] setFrame:[self.mainView bounds]];
}

- (IBAction)showEvaluations:(id)sender {
    
    [self.mainView addSubview:[_evaluationsViewController view]];
    [[_evaluationsViewController view] setFrame:[self.mainView bounds]];
}

- (IBAction)showResults:(id)sender {
    
    [self.mainView addSubview:[_resultsViewController view]];
    [[_resultsViewController view] setFrame:[self.mainView bounds]];
}

- (IBAction)toggleStart:(id)sender {
    

}


// NSToolbar delegates methods:

- (NSArray *)toolbarSelectableItemIdentifiers: (NSToolbar *)toolbar;
{

    return [NSArray arrayWithObjects:@"AppsView",
            @"ModulesView",
            @"EvaluationsView",
            @"ResultsView", nil];
}

//

- (void) dealloc {
    
    [_appsViewController release];
    [_modulesViewController release];
    [_evaluationsViewController release];
    [_resultsViewController release];
    [_apps release];
    [_scanner release];
    [super dealloc];
}

@end
