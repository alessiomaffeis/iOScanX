//
//  iSXAppController.h
//  iOScanX
//
//  Created by Alessio Maffeis on 28/05/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "iSXAppsViewController.h"
#include "iSXModulesViewController.h"
#include "iSXEvaluationsViewController.h"
#include "iSXResultsViewController.h"
#include "iSXApp.h"

@interface  iSXAppController : NSObject <NSWindowDelegate>

@property (assign) IBOutlet NSView *mainView;
@property (retain) NSMutableArray *apps;

- (void)initialize;

- (IBAction)showApps:(id)sender;
- (IBAction)showModules:(id)sender;
- (IBAction)showEvaluations:(id)sender;
- (IBAction)showResults:(id)sender;
- (IBAction)toggleStart:(id)sender;

@end