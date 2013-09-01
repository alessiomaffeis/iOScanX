//
//  iSXModulesViewController.h
//  iOScanX
//
//  Created by Alessio Maffeis on 20/06/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol iSXModulesViewDelegate

- (BOOL)addModule:(NSString*)path;

@end

@interface iSXModulesViewController : NSViewController

@property (assign) id <iSXModulesViewDelegate> delegate;

- (IBAction)add:(id)sender;
- (IBAction)delete:(id)sender;

@end
