//
//  iSXAppController.h
//  iOScanX
//
//  Created by Alessio Maffeis on 28/05/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ScanX/SXScanner.h>
#import <NMSSH/NMSSH.h>
#import "iSXImportViewController.h"
#import "iSXAppsViewController.h"
#import "iSXModulesViewController.h"
#import "iSXEvaluationsViewController.h"
#import "iSXResultsViewController.h"
#import "iSXProgressSheetController.h"
#import "iSXSelectWindowController.h"
#import "iSXApp.h"

@interface  iSXAppController : NSObject <NSWindowDelegate, iSXImportViewDelegate, iSXAppsViewDelegate, iSXModulesViewDelegate>

@property (assign) IBOutlet NSView *mainView;
@property (readonly) SXScanner *scanner;


- (void)initialize;

- (IBAction)showImport:(id)sender;
- (IBAction)showApps:(id)sender;
- (IBAction)showModules:(id)sender;
- (IBAction)showEvaluations:(id)sender;
- (IBAction)showResults:(id)sender;
- (IBAction)toggleStart:(id)sender;

@end