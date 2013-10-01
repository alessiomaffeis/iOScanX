//
//  iSXResultsViewController.h
//  iOScanX
//
//  Created by Alessio Maffeis on 20/06/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol iSXResultsViewDelegate

- (void)exportResults;

@end

@interface iSXResultsViewController : NSViewController <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (assign) id<iSXResultsViewDelegate> delegate;

- (void) updateResults:(NSMutableDictionary *)results;
- (IBAction)export:(id)sender;

@end
