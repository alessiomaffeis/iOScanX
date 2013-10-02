//
//  iSXResultsViewController.h
//  iOScanX
//
//  Created by Alessio Maffeis on 20/06/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iSXResult.h"

@protocol iSXResultsViewDelegate

- (void)exportResults;

@end

@interface iSXResultsViewController : NSViewController <NSTableViewDelegate>

@property (assign) id<iSXResultsViewDelegate> delegate;
@property (retain) NSMutableArray *results;

- (void)addResult:(iSXResult*)result;
- (void)removeAllResults;
- (IBAction)export:(id)sender;

@end
