//
//  iSXModulesViewController.h
//  iOScanX
//
//  Created by Alessio Maffeis on 20/06/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iSXModule.h"


@protocol iSXModulesViewDelegate

- (BOOL)addModules:(NSArray*)URLs;
- (void)deleteModule:(iSXModule*)module;

@end

@interface iSXModulesViewController : NSViewController <NSTableViewDelegate>

@property (assign) id <iSXModulesViewDelegate> delegate;
@property (retain) NSMutableArray *modules;

- (void)addModule:(iSXModule *)module;
- (BOOL)moduleExistsWithID:(NSString*)moduleID;
- (NSArray*)selectedModules;

- (IBAction)add:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)selectAll:(id)sender;

@end
